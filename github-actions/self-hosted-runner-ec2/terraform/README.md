# Terraform: self-hosted runner EC2 instance

Replaces the manual `aws ec2 run-instances` + SSH + `install-runner.sh` steps
from the parent [README](../README.md) with a single `terraform apply`. The
instance's `user_data` (`templates/user_data.sh.tpl`) does what
`../scripts/install-runner.sh` does manually, automatically at first boot.

## What it creates

- A security group with **no inbound rules by default** (runner only needs
  outbound HTTPS to poll GitHub). Optionally opens port 22 to a single CIDR if
  you set `ssh_cidr`, for debugging.
- One EC2 instance (Ubuntu 22.04, looked up dynamically via `data.aws_ami`, so
  you don't need to hardcode an AMI id per region).
- User-data that installs the runner agent and registers it against your repo
  on boot.

## Usage

1. Get a **registration token**: repo → Settings → Actions → Runners →
   New self-hosted runner. It expires in ~1 hour, so do this right before
   `apply`, not in advance.

2. Set variables. Because the token is a credential, prefer environment
   variables over a committed `.tfvars` file:

   ```bash
   export TF_VAR_key_name="my-keypair"
   export TF_VAR_github_repo_url="https://github.com/<owner>/<repo>"
   export TF_VAR_runner_registration_token="<paste token>"
   export TF_VAR_ssh_cidr="$(curl -s ifconfig.me)/32"   # optional, for SSH debugging
   ```

   (Or copy `terraform.tfvars.example` → `terraform.tfvars` and fill it in —
   just don't commit it; see `.gitignore` in the repo root.)

3. Apply:

   ```bash
   cd self-hosted-runner-ec2/terraform
   terraform init
   terraform plan
   terraform apply
   ```

4. Wait ~1-2 minutes for user-data to finish, then confirm the runner shows
   **Idle** under Settings → Actions → Runners in GitHub. If it doesn't show
   up, SSH in (if `ssh_cidr` was set) and check:

   ```bash
   ssh -i my-keypair.pem ubuntu@$(terraform output -raw instance_public_ip)
   sudo journalctl -u 'actions.runner.*' -f
   cloud-init status --long   # check user-data ran without errors
   ```

5. Run `../../.github/workflows/03-self-hosted.yml` via `workflow_dispatch`
   and confirm it executes on this instance.

## Tear down

The registration token used at boot is single-use for setup, but the runner
stays registered until removed. Deregister before destroying the instance so
GitHub doesn't show a stale/offline runner:

```bash
# get a removal token: Settings -> Actions -> Runners -> select runner -> Remove
ssh -i my-keypair.pem ubuntu@$(terraform output -raw instance_public_ip) \
  'cd actions-runner && ./config.sh remove --token <REMOVAL_TOKEN>'

terraform destroy
```

## Notes

- `user_data` is visible to anyone in the AWS account with
  `ec2:DescribeInstanceAttribute` permission — acceptable here since the
  token is short-lived, but don't reuse this pattern for long-lived secrets.
- To attach AWS API access for your jobs (e.g. deploying to S3/ECS), create an
  IAM instance profile separately and pass its name via `iam_instance_profile`.
- For real fleets, prefer ephemeral, auto-scaled runners over one long-lived
  hand-provisioned box — see the "Production notes" section in the parent
  README.
