#!/bin/bash

set -e

echo "Setting up nginx with mkcert for local HTTPS"

HOSTNAME=$(hostname)

echo "Detected hostname: $HOSTNAME"

# Detect the actual user if running with sudo
if [ -n "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
    ACTUAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    ACTUAL_USER="$USER"
    ACTUAL_HOME="$HOME"
fi

echo "Running as user: $ACTUAL_USER"

# Install libnss3-tools for browser certificate management
if ! command -v certutil &> /dev/null; then
    echo "Installing libnss3-tools for browser support..."
    sudo apt install -y libnss3-tools
fi

# Install mkcert if not already installed
if ! command -v mkcert &> /dev/null; then
    echo "Installing mkcert..."
    
    # Download and install mkcert
    MKCERT_VERSION="v1.4.4"
    wget -O /tmp/mkcert "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64"
    chmod +x /tmp/mkcert
    sudo mv /tmp/mkcert /usr/local/bin/mkcert
    
    echo "✓ mkcert installed"
fi

# Install the local CA in the system trust store as the actual user
echo "Installing mkcert CA in system trust store..."
if [ -n "$SUDO_USER" ]; then
    sudo -u "$ACTUAL_USER" HOME="$ACTUAL_HOME" mkcert -install
else
    mkcert -install
fi

# Create directory for certificates
sudo mkdir -p /etc/nginx/ssl
sudo chmod 755 /etc/nginx/ssl

# Generate certificates as the actual user, then copy to nginx directory
echo "Generating certificates for $HOSTNAME and localhost..."
TEMP_DIR=$(mktemp -d)
if [ -n "$SUDO_USER" ]; then
    sudo chown "$ACTUAL_USER:$ACTUAL_USER" "$TEMP_DIR"
fi
cd "$TEMP_DIR"

# Generate with explicit subdomains for better Chrome compatibility
if [ -n "$SUDO_USER" ]; then
    sudo -u "$ACTUAL_USER" HOME="$ACTUAL_HOME" mkcert -cert-file "$HOSTNAME.crt" -key-file "$HOSTNAME.key" \
        "$HOSTNAME" "*.$HOSTNAME" "localhost" "127.0.0.1" "::1" \
        "www.$HOSTNAME" "app.$HOSTNAME" "api.$HOSTNAME" "tmux.$HOSTNAME" \
        "dev.$HOSTNAME" "test.$HOSTNAME" "staging.$HOSTNAME"
else
    mkcert -cert-file "$HOSTNAME.crt" -key-file "$HOSTNAME.key" \
        "$HOSTNAME" "*.$HOSTNAME" "localhost" "127.0.0.1" "::1" \
        "www.$HOSTNAME" "app.$HOSTNAME" "api.$HOSTNAME" "tmux.$HOSTNAME" \
        "dev.$HOSTNAME" "test.$HOSTNAME" "staging.$HOSTNAME"
fi

# Copy certificates to nginx directory with proper permissions
sudo cp "$HOSTNAME.crt" "/etc/nginx/ssl/$HOSTNAME.crt"
sudo cp "$HOSTNAME.key" "/etc/nginx/ssl/$HOSTNAME.key"
sudo chmod 644 "/etc/nginx/ssl/$HOSTNAME.crt"
sudo chmod 600 "/etc/nginx/ssl/$HOSTNAME.key"

# Clean up temp directory
cd /
rm -rf "$TEMP_DIR"

echo "✓ Certificates generated successfully"

# Create nginx SSL configuration
echo "Creating nginx SSL configuration..."

sudo tee /etc/nginx/sites-available/port-forward-ssl > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    
    access_log off;
    error_log /var/log/nginx/port-forward-error.log warn;
    
    location / {
        proxy_pass http://localhost:4444;
        proxy_http_version 1.1;
        
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    
    server_name _;
    
    ssl_certificate /etc/nginx/ssl/$HOSTNAME.crt;
    ssl_certificate_key /etc/nginx/ssl/$HOSTNAME.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    access_log off;
    error_log /var/log/nginx/port-forward-ssl-error.log warn;
    
    location / {
        proxy_pass http://localhost:4444;
        proxy_http_version 1.1;
        
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Remove old symlink if exists
if [ -L /etc/nginx/sites-enabled/port-forward ]; then
    sudo rm /etc/nginx/sites-enabled/port-forward
fi

# Enable the SSL configuration
sudo ln -sf /etc/nginx/sites-available/port-forward-ssl /etc/nginx/sites-enabled/port-forward-ssl

# Update the repository config file
if [ -n "$SUDO_USER" ]; then
    sudo -u "$ACTUAL_USER" cp /etc/nginx/sites-available/port-forward-ssl "$ACTUAL_HOME/code/dotfiles/config/nginx/port-forward.conf"
else
    cp /etc/nginx/sites-available/port-forward-ssl "$HOME/code/dotfiles/config/nginx/port-forward.conf"
fi

echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✓ Nginx configuration is valid"
else
    echo "✗ Nginx configuration is invalid"
    exit 1
fi

# Reload nginx
sudo systemctl reload nginx

# Get the actual CA root for the user
if [ -n "$SUDO_USER" ]; then
    CA_ROOT=$(sudo -u "$ACTUAL_USER" HOME="$ACTUAL_HOME" mkcert -CAROOT)
else
    CA_ROOT=$(mkcert -CAROOT)
fi

echo ""
echo "=== mkcert SSL Setup Complete ==="
echo ""
echo "HTTPS is now available with browser-trusted certificates for:"
echo "  - https://localhost/"
echo "  - https://127.0.0.1/"
echo "  - https://$HOSTNAME/"
echo "  - https://*.$HOSTNAME/ (wildcard)"
echo ""
echo "Explicit subdomains included for better Chrome compatibility:"
echo "  - https://www.$HOSTNAME/"
echo "  - https://app.$HOSTNAME/"
echo "  - https://api.$HOSTNAME/"
echo "  - https://tmux.$HOSTNAME/"
echo "  - https://dev.$HOSTNAME/"
echo "  - https://test.$HOSTNAME/"
echo "  - https://staging.$HOSTNAME/"
echo ""
echo "Certificate details:"
echo "  - Certificate: /etc/nginx/ssl/$HOSTNAME.crt"
echo "  - Private key: /etc/nginx/ssl/$HOSTNAME.key"
echo "  - CA location: $CA_ROOT"
echo ""
echo "✓ All browsers including Chrome will trust these certificates automatically"
echo ""
echo "Note: For Chrome flatpak, you may need to manually import the CA:"
echo "  1. Open Chrome and go to chrome://settings/certificates"
echo "  2. Click 'Authorities' tab → 'Import'"
echo "  3. Select: $CA_ROOT/rootCA.pem"
echo "  4. Check 'Trust this certificate for identifying websites'"
echo ""
echo "If Chrome still shows 'Not secure' for wildcard domains:"
echo "  1. Clear Chrome's browsing data (cached images and files)"
echo "  2. Try accessing the explicit subdomain (e.g., tmux.$HOSTNAME) instead of wildcard"
echo "  3. Restart Chrome completely"
echo ""