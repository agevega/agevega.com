#!/bin/bash

# Configuration
DOMAIN="agevega.com"
EMAIL="admin@agevega.com" # Replace with valid email if needed

# 1. Install Certbot
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    sudo dnf install -y certbot python3-certbot-dns-route53
else
    echo "Certbot is already installed."
fi

# 2. Stop existing frontend
echo "Stopping any running frontend container..."
sudo docker stop frontend || true

# 3. Request Certificate (Using Route53)
echo "Requesting certificate for $DOMAIN and www.$DOMAIN using Route53..."
sudo certbot certonly --dns-route53 \
  -d "$DOMAIN" -d "www.$DOMAIN" \
  --email "$EMAIL" \
  --agree-tos \
  --non-interactive \
  --keep-until-expiring

echo "------------------------------------------------"
echo "Certificate setup finished."
echo "Certificates location: /etc/letsencrypt/live/$DOMAIN/"
