#!/usr/bin/env bash
set -euo pipefail

# Example long task (replace with your real setup)
sleep 30

# Do your real provisioning here...
# apt-get update && apt-get install -y nginx
# kubectl apply -f something.yaml
# etc.

# Signal readiness
touch /tmp/.scenario_ready
