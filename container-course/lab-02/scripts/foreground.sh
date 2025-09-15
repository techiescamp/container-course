#!/bin/bash

echo "Waiting for nginx to start..." >/dev/tty
for i in {1..180}; do
    if systemctl is-active --quiet nginx; then
        break
    fi
    sleep 1
done

# Check if nginx is running
if systemctl is-active --quiet nginx; then
    echo "Nginx is running."
else
    echo "Nginx is not running after waiting."
    exit 1
fi