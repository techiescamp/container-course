#!/usr/bin/env bash
set -euo pipefail

# show echo messages on terminal
echo "Starting background setup..."

# redirect rest of logs to file
{
  # simulate a long setup
  sleep 25

  # e.g. apt-get update && apt-get install -y nginx
  touch /tmp/.scenario_ready
} >>/tmp/setup.log 2>&1
