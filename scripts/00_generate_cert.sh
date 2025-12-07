#!/bin/bash

# Configuration
DOMAIN="agevega.com"
EMAIL="admin@agevega.com" # Replace with valid email if needed

# 1. Install Certbot
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    sudo dnf install -y certbot
else
    echo "Certbot is already installed."
fi

# 2. Stop existing frontend
echo "Stopping any running frontend container..."
sudo docker stop frontend || true

# 3. Request Certificate
echo "Requesting certificate for $DOMAIN and www.$DOMAIN..."
sudo certbot certonly --standalone \
  -d "$DOMAIN" -d "www.$DOMAIN" \
  --email "$EMAIL" \
  --agree-tos \
  --non-interactive \
  --keep-until-expiring

echo "------------------------------------------------"
echo "Certificate setup finished."
echo "Certificates location: /etc/letsencrypt/live/$DOMAIN/"
