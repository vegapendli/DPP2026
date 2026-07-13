#!/usr/bin/env bash
# Installs and registers a GitHub Actions self-hosted runner on this EC2 instance,
# then runs it as a systemd service (svc.sh) so it survives reboots.
#
# Usage (run on the EC2 instance, as a user with sudo):
#   ./install-runner.sh https://github.com/<OWNER>/<REPO> <REGISTRATION_TOKEN> [runner-name]
#
# Get the registration token from:
#   GitHub repo -> Settings -> Actions -> Runners -> New self-hosted runner
# It expires after ~1 hour, so run this script shortly after generating it.

set -euo pipefail

REPO_URL="${1:?Usage: $0 <repo-url> <registration-token> [runner-name]}"
REG_TOKEN="${2:?Usage: $0 <repo-url> <registration-token> [runner-name]}"
RUNNER_NAME="${3:-$(hostname)}"
RUNNER_VERSION="2.319.1"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) RUNNER_ARCH="x64" ;;
  aarch64) RUNNER_ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

sudo apt-get update -y
sudo apt-get install -y curl tar jq

mkdir -p ~/actions-runner && cd ~/actions-runner

curl -o actions-runner.tar.gz -L \
  "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"
tar xzf actions-runner.tar.gz
rm actions-runner.tar.gz

./config.sh --url "$REPO_URL" --token "$REG_TOKEN" --name "$RUNNER_NAME" \
  --labels self-hosted,linux,ec2 --unattended --replace

sudo ./svc.sh install
sudo ./svc.sh start

echo "Runner '$RUNNER_NAME' installed and started. Check status with:"
echo "  sudo ./svc.sh status"
echo "It should now show as 'Idle' under Settings -> Actions -> Runners in GitHub."
