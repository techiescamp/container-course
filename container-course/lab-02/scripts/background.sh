#!/usr/bin/env bash
# /usr/local/bin/background.sh
set -euo pipefail
exec >>/tmp/setup.log 2>&1

# your real setup
sleep 30
# e.g. apt-get update && apt-get install -y nginx

touch /tmp/.scenario_ready
