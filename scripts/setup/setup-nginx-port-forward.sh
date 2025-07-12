#!/bin/bash

set -e

echo "Setting up nginx port forwarding (80 -> 4444)"

# Check if nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "nginx is not installed. Installing..."
    sudo apt update
    sudo apt install -y nginx
fi

# Stop nginx if running
sudo systemctl stop nginx || true

# Disable default site
if [ -L /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
    echo "Disabled default nginx site"
fi

# Create sites directories if they don't exist
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

# Copy our configuration
sudo cp $PWD/config/nginx/port-forward.conf /etc/nginx/sites-available/port-forward

# Enable our site
sudo ln -sf /etc/nginx/sites-available/port-forward /etc/nginx/sites-enabled/port-forward

# Test nginx configuration
echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✓ nginx configuration is valid"
else
    echo "✗ nginx configuration is invalid"
    exit 1
fi

# Enable nginx service
sudo systemctl enable nginx

# Start nginx service
sudo systemctl start nginx

# Check if service is running
if sudo systemctl is-active --quiet nginx; then
    echo "✓ nginx is running"
else
    echo "✗ nginx failed to start"
    exit 1
fi

echo "nginx port forwarding setup complete!"
echo "Port 80 is now forwarding to port 4444"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status nginx    # Check status"
echo "  sudo systemctl stop nginx      # Stop forwarding"
echo "  sudo systemctl start nginx     # Start forwarding"
echo "  sudo journalctl -u nginx       # View logs"