#!/bin/bash

set -e

echo "Setting up SSL for nginx with wildcard certificate"

HOSTNAME=$(hostname)

echo "Detected hostname: $HOSTNAME"

if ! command -v openssl &> /dev/null; then
    echo "OpenSSL is not installed. Installing..."
    sudo apt update
    sudo apt install -y openssl ca-certificates
fi

sudo mkdir -p /etc/nginx/ssl
sudo chmod 700 /etc/nginx/ssl

CERT_FILE="/etc/nginx/ssl/$HOSTNAME.crt"
KEY_FILE="/etc/nginx/ssl/$HOSTNAME.key"

if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "SSL certificate already exists for $HOSTNAME"
    echo "To regenerate, remove $CERT_FILE and $KEY_FILE first"
else
    echo "Generating self-signed wildcard certificate..."
    
    CONFIG_FILE="/tmp/openssl-san.cnf"
    cat > "$CONFIG_FILE" <<EOF
[req]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Local Development
CN = $HOSTNAME

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $HOSTNAME
DNS.2 = *.$HOSTNAME
EOF

    sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -config "$CONFIG_FILE" \
        -extensions v3_req
    
    rm -f "$CONFIG_FILE"
    
    sudo chmod 600 "$KEY_FILE"
    sudo chmod 644 "$CERT_FILE"
    
    echo "✓ Certificate generated successfully"
fi

echo "Adding certificate to system trust store..."
sudo cp "$CERT_FILE" "/usr/local/share/ca-certificates/$HOSTNAME.crt"
sudo update-ca-certificates

echo "✓ Certificate added to system trust store"

if [ -f /etc/nginx/sites-available/port-forward-ssl ]; then
    echo "SSL nginx configuration already exists"
else
    echo "Creating SSL nginx configuration..."
    
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
fi

if [ -L /etc/nginx/sites-enabled/port-forward ]; then
    sudo rm /etc/nginx/sites-enabled/port-forward
fi

sudo ln -sf /etc/nginx/sites-available/port-forward-ssl /etc/nginx/sites-enabled/port-forward-ssl

echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✓ Nginx configuration is valid"
else
    echo "✗ Nginx configuration is invalid"
    exit 1
fi

sudo systemctl reload nginx

echo ""
echo "=== SSL Setup Complete ==="
echo ""
echo "HTTPS is now available on port 443 for:"
echo "  - https://$HOSTNAME/"
echo "  - https://*.$HOSTNAME/"
echo ""
echo "Certificate details:"
echo "  - Certificate: $CERT_FILE"
echo "  - Private key: $KEY_FILE"
echo "  - Valid for: 10 years"
echo ""
echo "Browser trust status:"
echo "  ✓ Chrome/Chromium - Automatically trusted (Linux)"
echo "  ✓ System tools (curl, wget) - Automatically trusted"
echo "  ⚠ Firefox - Manual trust required:"
echo ""
echo "To trust in Firefox:"
echo "  1. Visit https://$HOSTNAME"
echo "  2. Click 'Advanced' on the warning page"
echo "  3. Click 'Accept the Risk and Continue'"
echo "  4. For permanent trust: Settings → Privacy & Security → View Certificates"
echo "     → Import → Select $CERT_FILE"
echo ""