#!/bin/bash

set -e

echo "Configuring NordVPN firewall rules for local nginx access"

# Check if NordVPN rules exist
if ! sudo nft list ruleset | grep -q "100.64.0.0/10"; then
    echo "Error: NordVPN firewall rules not found. Is NordVPN installed and connected?"
    exit 1
fi

# Add rules to allow local nginx access when using NordVPN
# These rules allow traffic from the VPN interface to local addresses on nginx ports
echo "Adding firewall rules..."

# Find the position before the drop rule and insert our accept rules
# We need to insert these rules in the INPUT chain before the "ip saddr 100.64.0.0/10 drop" rule

# Add rules using iptables-nft which NordVPN uses
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 127.0.0.1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 127.0.0.1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 192.168.0.0/16 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 192.168.0.0/16 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 172.16.0.0/12 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 172.16.0.0/12 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 10.0.0.0/8 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -s 100.64.0.0/10 -d 10.0.0.0/8 -p tcp --dport 443 -j ACCEPT

echo "Making rules persistent..."
sudo nft list ruleset > /tmp/nftables.conf
sudo cp /tmp/nftables.conf /etc/nftables.conf
rm /tmp/nftables.conf

echo "✓ Firewall rules added successfully"
echo ""
echo "You should now be able to access nginx via browser at:"
echo "  - https://localhost"
echo "  - https://127.0.0.1"  
echo "  - https://$(hostname)"
echo "  - https://$(ip addr show | grep "inet " | grep -v "127.0.0.1" | head -1 | awk '{print $2}' | cut -d'/' -f1)"
echo ""
echo "Note: You'll still get a 502 error until you start a service on port 4444"