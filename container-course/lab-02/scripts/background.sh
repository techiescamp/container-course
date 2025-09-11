#!/usr/bin/env bash
set -euo pipefail
exec >>/tmp/setup.log 2>&1

# simulate a long setup
sleep 25

# e.g. apt-get update && apt-get install -y nginx
touch /tmp/.scenario_ready
