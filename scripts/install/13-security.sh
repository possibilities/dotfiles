#!/bin/bash

set -e

VERACRYPT_VERSION="1.26.14"

echo "install nordvpn"

sh <(curl -ssf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER

echo "configure nordvpn firewall rules for local nginx access"

# Allow local nginx access when using NordVPN
# This permits browser connections to localhost nginx while VPN is active
# Note: NordVPN uses iptables-nft, so we use iptables commands
# These rules must be inserted before the drop rule, so we insert at position 1
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 127.0.0.1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 127.0.0.1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 192.168.0.0/16 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 192.168.0.0/16 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 172.16.0.0/12 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 172.16.0.0/12 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 10.0.0.0/8 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 10.0.0.0/8 -p tcp --dport 443 -j ACCEPT

# Make rules persistent using iptables-save
sudo iptables-save > /tmp/iptables.rules
sudo cp /tmp/iptables.rules /etc/iptables/rules.v4 2>/dev/null || true
rm /tmp/iptables.rules

echo "install veracrypt"

cd ${HOME}/src
wget "https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb"
sudo apt install --yes ./veracrypt-${VERACRYPT_VERSION}-Debian-12-amd64.deb