#!/bin/bash

DOMAIN="agevega.com"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
IMAGE_NAME="${1:-frontend:latest}" # Use first argument as image name, default to frontend:latest

# 1. Check for certificates
if ! sudo test -d "$CERT_PATH"; then
    echo "Certificates not found at $CERT_PATH"
    echo "Attempting to generate certificates..."
    
    if [ -f "./00_generate_cert.sh" ]; then
        chmod +x ./00_generate_cert.sh
        # Run cert generation
        ./00_generate_cert.sh
        
        # Verify again
        if ! sudo test -d "$CERT_PATH"; then
             echo "Error: Certificate generation failed. Certificates still not found."
             exit 1
        fi
    else
        echo "Error: 00_generate_cert.sh not found. Cannot generate certificates."
        echo "Please run scripts/00_generate_cert.sh manually first."
        exit 1
    fi
fi

# 2. Prepare Certificates (Dereference Symlinks)
# Docker bind mounts usually cannot follow symlinks that point outside the mount.
# We copy them to a staging directory to ensure the container gets actual files.
STAGING_DIR="$HOME/agevega_certs"
mkdir -p "$STAGING_DIR"

echo "Staging certificates..."
sudo cp -L "$CERT_PATH/fullchain.pem" "$STAGING_DIR/fullchain.pem"
sudo cp -L "$CERT_PATH/privkey.pem" "$STAGING_DIR/privkey.pem"
sudo chown -R $USER:$USER "$STAGING_DIR"

# 3. Re-deploy container
echo "Stopping old container..."
docker stop frontend || true
docker rm frontend || true

echo "Removing local image to force re-pull..."
docker rmi -f "$IMAGE_NAME" || true

echo "Starting new container with SSL..."
docker run -d \
  --restart always \
  -p 80:80 -p 443:443 \
  -v "$STAGING_DIR:/etc/nginx/certs:ro" \
  --name frontend \
  "$IMAGE_NAME"

echo "Frontend deployed successfully."
