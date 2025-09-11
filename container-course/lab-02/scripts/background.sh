#!/usr/bin/env bash
set -euo pipefail
exec >>/tmp/setup.log 2>&1

sleep 30   # simulate long setup
touch /tmp/.scenario_ready
