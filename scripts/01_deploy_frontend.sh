#!/bin/bash

IMAGE_NAME="${1:-frontend:latest}"

# Stop and remove old container
echo "Stopping old container..."
docker stop frontend || true
docker rm frontend || true

# Remove local image to force re-pull
echo "Removing local image to force re-pull..."
docker rmi -f "$IMAGE_NAME" || true

# Extract tag from IMAGE_NAME (everything after the last colon)
TAG="${IMAGE_NAME##*:}"
echo "Detected Deployment Version: $TAG"

DOMAIN="${2:-dev.agevega.com}"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

# 1. Check for certificates
if [ ! -f "$CERT_PATH/fullchain.pem" ] || [ ! -f "$CERT_PATH/privkey.pem" ]; then
    echo "Certificates not found at $CERT_PATH"
    echo "Attempting to generate certificates..."
    
    if [ -f "./00_generate_cert.sh" ]; then
        chmod +x ./00_generate_cert.sh
        # Run cert generation
        ./00_generate_cert.sh "$DOMAIN" "admin@agevega.com"
    else
        echo "Error: 00_generate_cert.sh not found."
        exit 1
    fi
fi

# 2. Stage Certificates (Fix for Docker symlink/permission issues)
STAGING_DIR="$HOME/certs/$DOMAIN"
echo "Staging certificates to $STAGING_DIR..."
mkdir -p "$STAGING_DIR"
sudo cp -L "$CERT_PATH/fullchain.pem" "$STAGING_DIR/server.crt"
sudo cp -L "$CERT_PATH/privkey.pem"   "$STAGING_DIR/server.key"
sudo chown -R $USER:$USER "$STAGING_DIR"
chmod 600 "$STAGING_DIR/server.key"

# 3. Start new container
echo "Starting new container for domain: $DOMAIN..."
docker run -d \
  --restart always \
  -p 443:443 \
  -v "$STAGING_DIR/server.crt:/etc/nginx/server.crt:ro" \
  -v "$STAGING_DIR/server.key:/etc/nginx/server.key:ro" \
  -e DEPLOYMENT_VERSION="$TAG" \
  --name frontend \
  "$IMAGE_NAME"

echo "Frontend deployed successfully."

# Cleanup unused images
echo "Pruning unused images..."
docker image prune -a -f
