#!/usr/bin/env bash
set -euo pipefail

# start background work
/usr/local/bin/background.sh >/tmp/setup.log 2>&1 & disown

echo "Scenario is loading... please wait."
for i in $(seq 1 180); do
  if [[ -f /tmp/.scenario_ready ]]; then
    echo "Setup complete!"
    exit 0
  fi
  printf "."
  sleep 1
done

echo
echo "Setup took too long. Please reload the scenario."
exit 1
