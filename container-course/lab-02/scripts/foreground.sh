#!/usr/bin/env bash
set -euo pipefail

# Start the long job in the background
/usr/local/bin/background.sh &

echo ""
echo "Scenario is loading... please wait."
echo ""

# Wait until the background job drops a ready file
for i in $(seq 1 120); do
  if [[ -f /tmp/.scenario_ready ]]; then
    echo "Setup complete!"
    exit 0
  fi
  printf "."
  sleep 1
done

echo ""
echo "Setup took too long. Please reload the scenario."
exit 1
