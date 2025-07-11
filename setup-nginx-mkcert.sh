#!/bin/bash

set -e

echo "Setting up nginx with mkcert for local HTTPS"

HOSTNAME=$(hostname)

echo "Detected hostname: $HOSTNAME"

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

# Install the local CA in the system trust store
echo "Installing mkcert CA in system trust store..."
mkcert -install

# Create directory for certificates
sudo mkdir -p /etc/nginx/ssl
sudo chmod 755 /etc/nginx/ssl

# Generate certificates for hostname and common variations
echo "Generating certificates for $HOSTNAME and localhost..."
cd /etc/nginx/ssl
sudo mkcert -cert-file "$HOSTNAME.crt" -key-file "$HOSTNAME.key" \
    "$HOSTNAME" "*.$HOSTNAME" "localhost" "127.0.0.1" "::1"

# Set proper permissions
sudo chmod 644 "/etc/nginx/ssl/$HOSTNAME.crt"
sudo chmod 600 "/etc/nginx/ssl/$HOSTNAME.key"

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
cp /etc/nginx/sites-available/port-forward-ssl "$HOME/code/dotfiles/config/nginx/port-forward.conf"

echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✓ Nginx configuration is valid"
else
    echo "✗ Nginx configuration is invalid"
    exit 1
fi

# Reload nginx
sudo systemctl reload nginx

echo ""
echo "=== mkcert SSL Setup Complete ==="
echo ""
echo "HTTPS is now available with browser-trusted certificates for:"
echo "  - https://localhost/"
echo "  - https://127.0.0.1/"
echo "  - https://$HOSTNAME/"
echo "  - https://*.$HOSTNAME/"
echo ""
echo "Certificate details:"
echo "  - Certificate: /etc/nginx/ssl/$HOSTNAME.crt"
echo "  - Private key: /etc/nginx/ssl/$HOSTNAME.key"
echo "  - CA location: $(mkcert -CAROOT)"
echo ""
echo "✓ All browsers including Chrome will trust these certificates automatically"
echo ""
echo "Note: For Chrome flatpak, you may need to manually import the CA:"
echo "  1. Open Chrome and go to chrome://settings/certificates"
echo "  2. Click 'Authorities' tab → 'Import'"
echo "  3. Select: $(mkcert -CAROOT)/rootCA.pem"
echo "  4. Check 'Trust this certificate for identifying websites'"
echo ""