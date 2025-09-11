#!/bin/bash

# Wait for nginx to start
sleep 15

# Check if nginx is running
if systemctl is-active --quiet nginx; then
    echo "Nginx is running."
else 
    echo "Nginx is not running."
    exit 1
fi