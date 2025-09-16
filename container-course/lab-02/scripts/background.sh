#!/bin/bash

sudo apt update -y
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

sudo sed -i 's/^worker_processes .*/worker_processes 4;/' /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl reload nginx
