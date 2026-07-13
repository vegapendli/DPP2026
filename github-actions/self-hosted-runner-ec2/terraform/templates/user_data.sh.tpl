#!/usr/bin/env bash
# EC2 user-data: runs once as root at first boot. Installs and registers the
# GitHub Actions runner, then starts it as a systemd service under the
# "ubuntu" user (the runner refuses to run config.sh/svc.sh as root).
set -euo pipefail

RUNNER_VERSION="2.319.1"

apt-get update -y
apt-get install -y curl tar jq

runuser -l ubuntu -c "
  set -euo pipefail
  mkdir -p ~/actions-runner && cd ~/actions-runner
  curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
  tar xzf actions-runner.tar.gz
  rm actions-runner.tar.gz
  ./config.sh --url ${github_repo_url} --token ${runner_token} --name ${runner_name} --labels self-hosted,linux,ec2 --unattended --replace
"

cd /home/ubuntu/actions-runner
./svc.sh install ubuntu
./svc.sh start
