#!/usr/bin/env bash
set -euo pipefail
echo "Scenario is loading... please wait."
for i in $(seq 1 120); do
  [[ -f /tmp/.scenario_ready ]] && echo "Setup complete!" && exit 0
  printf "."
  sleep 1
done
echo "Setup took too long. Please reload the scenario."
exit 1
