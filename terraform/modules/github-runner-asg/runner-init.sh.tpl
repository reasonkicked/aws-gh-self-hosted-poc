#!/usr/bin/env bash
set -eux
# Install dependencies
sysctl -n kernel.pid_max
curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name
TOKEN=$(curl -sX POST -H "Authorization: bearer $GH_TOKEN" https://api.github.com/orgs/$GH_ORG/actions/runners/registration-token | jq -r .token)
/opt/actions/config.sh --url "https://github.com/$GH_ORG" --token "$TOKEN" --labels "$labels" --unattended
nohup /opt/actions/bin/runsvc.sh &
# Debug: list running processes
ps aux | grep runsvc
# Idle-shutdown
while sleep 60; do
  if ! pgrep -f runsvc.sh; then shutdown -h now; fi
done