#!/usr/bin/env bash
# /usr/local/bin/foreground.sh
set +xv   # make sure no command echoing
tput civis || true
trap 'tput cnorm >/dev/null 2>&1 || true' EXIT

echo
echo "Scenario is loading... please wait."
echo

for i in $(seq 1 120); do
  if [[ -f /tmp/.scenario_ready ]]; then
    echo
    echo "Setup complete!"
    exit 0
  fi
  printf "."
  sleep 1
done

echo
echo "Setup is taking longer than expected. Please reload the scenario."
exit 1
