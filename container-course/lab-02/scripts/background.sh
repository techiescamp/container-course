#!/usr/bin/env bash
set -euo pipefail
exec >>/tmp/setup.log 2>&1

# long setup here (example)
sleep 30
# apt-get update && apt-get install -y nginx
# systemctl start nginx

touch /tmp/.scenario_ready
