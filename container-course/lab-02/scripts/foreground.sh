#!/usr/bin/env bash
set -euo pipefail

# Launch background setup
/usr/local/bin/background.sh >/tmp/setup.log 2>&1 & disown

msg="Installing Nginx (this can take a bit)"
dots=""
echo -n "$msg"

# Loop until ready file exists
for i in $(seq 1 180); do
  if [[ -f /tmp/.scenario_ready ]]; then
    echo -e "\r✅ $msg ... Done!"
    exit 0
  fi
  dots="${dots}."
  printf "\r%s %s" "$msg" "$dots"
  sleep 1
done

echo -e "\n⚠️ Setup took too long. Please reload the scenario."
exit 1
