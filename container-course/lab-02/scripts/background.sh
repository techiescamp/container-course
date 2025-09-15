#!/usr/bin/env bash
set -euo pipefail

# simulate a long setup
echo "Starting background setup..." >/dev/tty
sleep 25

# e.g. apt-get update && apt-get install -y nginx
touch /tmp/.scenario_ready
