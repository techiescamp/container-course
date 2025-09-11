#!/usr/bin/env bash
set -euo pipefail
exec >>/tmp/setup.log 2>&1

# long setup here
sleep 30

touch /tmp/.scenario_ready
