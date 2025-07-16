#!/bin/bash
set -e

echo "install nordvpn"

sh <(curl -ssf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER