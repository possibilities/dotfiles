#!/bin/bash

set -e

echo "Setting up wildcard DNS for local hostname with NordVPN compatibility"

# Get the current hostname
HOSTNAME=$(hostname)

echo "Detected hostname: $HOSTNAME"

# Install resolvconf if not present
if ! command -v resolvconf &> /dev/null; then
    echo "Installing resolvconf..."
    sudo apt-get update
    sudo apt-get install -y resolvconf
fi

# Stop dnsmasq if it's running
sudo systemctl stop dnsmasq || true

# Backup existing dnsmasq configuration if it exists
if [ -f /etc/dnsmasq.conf ]; then
    sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup
fi

# Create main dnsmasq configuration
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
# Main dnsmasq configuration for wildcard hostname resolution

# Listen on localhost only, standard DNS port
listen-address=127.0.0.1
bind-interfaces

# Wildcard resolution for hostname and all subdomains
address=/$HOSTNAME/127.0.0.1

# Forward all other queries to upstream DNS servers
# Get them from the system resolver
resolv-file=/etc/resolv.dnsmasq.conf

# Enable dnsmasq.d directory for additional configs
conf-dir=/etc/dnsmasq.d

# Cache size
cache-size=1000

# Log queries (can be commented out after testing)
#log-queries
EOF

# Create dnsmasq configuration directory
sudo mkdir -p /etc/dnsmasq.d

# Save current nameservers for dnsmasq to use as upstream
if [ -f /etc/resolv.conf ]; then
    grep "^nameserver" /etc/resolv.conf | sudo tee /etc/resolv.dnsmasq.conf > /dev/null
fi

# Enable and start dnsmasq service
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

# Wait a moment for service to stabilize
sleep 2

# Create a resolvconf configuration to prepend local dnsmasq
sudo mkdir -p /etc/resolvconf/resolv.conf.d

# Create head file to prepend dnsmasq to resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolvconf/resolv.conf.d/head > /dev/null

# Update resolvconf
sudo resolvconf -u

# Create a NetworkManager dispatcher script to maintain our DNS settings
sudo mkdir -p /etc/NetworkManager/dispatcher.d

sudo tee /etc/NetworkManager/dispatcher.d/10-wildcard-dns > /dev/null <<'EOF'
#!/bin/bash
# Maintain local dnsmasq as primary DNS resolver

case "$2" in
    up|dhcp4-change|dhcp6-change)
        # Ensure our local dnsmasq is always first
        if ! grep -q "^nameserver 127.0.0.1" /etc/resolv.conf; then
            # Create temporary file with our nameserver first
            echo "nameserver 127.0.0.1" > /tmp/resolv.conf.new
            grep "^nameserver" /etc/resolv.conf | grep -v "127.0.0.1" >> /tmp/resolv.conf.new
            grep -v "^nameserver" /etc/resolv.conf >> /tmp/resolv.conf.new
            sudo mv /tmp/resolv.conf.new /etc/resolv.conf
        fi
        
        # Update dnsmasq upstream servers
        grep "^nameserver" /etc/resolv.conf | grep -v "127.0.0.1" | sudo tee /etc/resolv.dnsmasq.conf > /dev/null
        sudo systemctl reload dnsmasq
        ;;
esac
EOF

sudo chmod +x /etc/NetworkManager/dispatcher.d/10-wildcard-dns

# Test the configuration
echo -e "\nTesting DNS resolution..."

# Force update of resolv.conf
if ! grep -q "^nameserver 127.0.0.1" /etc/resolv.conf; then
    # Create temporary file with our nameserver first
    echo "nameserver 127.0.0.1" > /tmp/resolv.conf.new
    grep "^nameserver" /etc/resolv.conf | grep -v "127.0.0.1" >> /tmp/resolv.conf.new
    grep -v "^nameserver" /etc/resolv.conf >> /tmp/resolv.conf.new
    sudo mv /tmp/resolv.conf.new /etc/resolv.conf
fi

sleep 1

# Test using system resolver
if getent hosts $HOSTNAME | grep -q "127\."; then
    echo "✓ Base hostname resolves correctly"
else
    echo "✗ Base hostname resolution failed"
fi

if getent hosts test.$HOSTNAME | grep -q "127.0.0.1"; then
    echo "✓ Wildcard subdomain resolves correctly"
else
    echo "✗ Wildcard subdomain resolution failed"
fi

echo -e "\nWildcard DNS setup complete for hostname: $HOSTNAME"
echo "The system is now configured to use local DNS for wildcard resolution while maintaining NordVPN connectivity."