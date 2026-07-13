# Module 03 — Self-Hosted GitHub Actions Runner on AWS EC2

Continues the series from `01-hello-world.yml` and `02-multi-job.yml`, which both
used GitHub-hosted runners (`runs-on: ubuntu-latest`). This module replaces that
with your own EC2 instance as the runner.

## 1. Hosted vs self-hosted runners

| | GitHub-hosted | Self-hosted |
|---|---|---|
| Who manages the machine | GitHub | You |
| Cost | Free minutes, then per-minute billing | You pay EC2 cost directly, no per-minute Actions billing |
| Startup | Fresh VM every run | Persistent — state/cache can survive between runs |
| Access to private network (VPC, internal DB) | No | Yes, if the EC2 instance is in that VPC |
| Custom hardware / software (GPU, licensed tools, specific OS) | Limited to GitHub's images | Whatever you install |
| Security responsibility | GitHub patches the image | You patch the OS, rotate the runner, secure the box |

Use self-hosted when you need: access to a private VPC/on-prem resource, specific
hardware, or you want to avoid Actions minutes billing on a high-volume repo.

## 2. How it works

1. You launch an EC2 instance.
2. You install the GitHub Actions **runner agent** on it and register it against
   a repo (or org) using a registration token from GitHub.
3. The runner agent opens an **outbound** long-poll connection to GitHub — no
   inbound ports need to be opened, so a private-subnet EC2 instance still works.
4. When a workflow specifies `runs-on: [self-hosted, ...]`, GitHub dispatches the
   job to your runner instead of a GitHub-hosted VM.
5. Jobs run directly on the EC2 instance's OS/filesystem — unlike hosted runners,
   nothing is wiped between jobs unless you clean up yourself.

```
GitHub.com                         Your AWS Account
┌───────────────┐   outbound       ┌───────────────────┐
│ Actions        │ <--- poll ----- │ EC2 instance        │
│ job queue      │ --- job data--> │ (runner agent proc) │
└───────────────┘                 └───────────────────┘
```

## 3. Hands-on: stand up the runner

Two ways to do this — pick one:

- **Manual (below)**: `aws ec2 run-instances` + SSH + run `scripts/install-runner.sh`
  yourself. Good for understanding each step.
- **Terraform**: [`terraform/`](terraform/) provisions the same instance +
  security group and runs the install automatically via `user_data`. See
  [`terraform/README.md`](terraform/README.md). Good once you've done the
  manual path once and want it repeatable/disposable.

### Step 1 — Launch the EC2 instance

Via AWS Console or CLI. Minimum viable setup:

- AMI: Ubuntu 22.04 LTS
- Instance type: `t3.micro` (fine for this demo; scale up for real workloads)
- Security group: **no inbound rules needed** for the runner itself (only add
  inbound 22 if you want SSH access to debug)
- IAM role: none required just for the runner; attach one later if your jobs
  need to call AWS APIs (e.g. deploy to S3/ECS)

```bash
aws ec2 run-instances \
  --image-id ami-0XXXXXXXXXXXXXXXX \
  --instance-type t3.micro \
  --key-name my-keypair \
  --security-group-ids sg-xxxxxxxx \
  --subnet-id subnet-xxxxxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=gha-self-hosted-runner}]'
```

(Replace the AMI id with a current Ubuntu 22.04 id for your region — look it up
with `aws ec2 describe-images` or the AWS Console.)

### Step 2 — Get a registration token from GitHub

In your repo: **Settings → Actions → Runners → New self-hosted runner**.
GitHub shows you an OS-specific config command containing a short-lived
registration token. You need that token for Step 3 (it expires in ~1 hour).

Or via API/CLI (needs a PAT with `repo` scope):

```bash
curl -s -X POST \
  -H "Authorization: token <YOUR_PAT>" \
  https://api.github.com/repos/<OWNER>/<REPO>/actions/runners/registration-token \
  | jq -r .token
```

### Step 3 — Install and register the runner on the EC2 instance

SSH into the instance, then run `scripts/install-runner.sh` from this directory
(copy it up first, or paste its contents), passing your repo URL and token:

```bash
scp scripts/install-runner.sh ubuntu@<EC2_PUBLIC_IP>:~/
ssh ubuntu@<EC2_PUBLIC_IP>
./install-runner.sh https://github.com/<OWNER>/<REPO> <REGISTRATION_TOKEN>
```

This downloads the runner binary, configures it against your repo, and starts it
as a systemd service so it survives reboots and keeps polling for jobs.

Confirm it shows up **Idle** under Settings → Actions → Runners in GitHub.

### Step 4 — Point a workflow at it

`../.github/workflows/03-self-hosted.yml` (added alongside this module) uses
`runs-on: [self-hosted, linux, x64]` instead of `ubuntu-latest`. Push it and
watch the job execute on your EC2 box — check `htop` or `journalctl -u
actions.runner.* -f` on the instance while it runs.

### Step 5 — Clean up

Self-hosted runners are billed as your own EC2 cost, and idle instances still
cost money. When done:

```bash
# on the instance, deregister first
cd actions-runner && ./config.sh remove --token <REMOVAL_TOKEN>

# then terminate the instance
aws ec2 terminate-instances --instance-ids i-xxxxxxxxxxxxxxxxx
```

Get a removal token the same way as the registration token, from
Settings → Actions → Runners → select the runner → Remove.

## 4. Production notes (beyond this demo)

- **Labels**: tag runners (`runs-on: [self-hosted, gpu]`) to target specific
  hardware/capability sets when you have more than one runner.
- **Ephemeral runners**: set `--ephemeral` in `config.sh` so the runner
  deregisters itself after one job — combine with EC2 Auto Scaling to spin up a
  fresh, clean instance per job (avoids state leaking between jobs/PRs).
- **Security**: self-hosted runners on *public* repos are a known attack vector
  — anyone who can open a PR can get code execution on your runner. Restrict to
  private repos, or require approval for workflows from forks
  (Settings → Actions → Fork pull request workflows).
- **Scaling**: for real workloads, look at the official
  [actions-runner-controller](https://github.com/actions/actions-runner-controller)
  (Kubernetes) or an EC2 Auto Scaling group with a Lambda that registers/removes
  runners on scale events, instead of one hand-managed box.
