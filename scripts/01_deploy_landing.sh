#!/bin/bash
set -euo pipefail

DOMAIN="agevega.com"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
# No default: ECR tags are immutable and :latest is never pushed, so the caller
# must pass the full image URI with an explicit version tag.
IMAGE_NAME="${1:?Usage: $0 <image-uri:version-tag>}"

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
sudo chown -R "$(whoami):$(whoami)" "$STAGING_DIR"

# 3. Re-deploy container
echo "Stopping old container..."
docker stop landing || true
docker rm landing || true

echo "Removing local image to force re-pull..."
docker rmi -f "$IMAGE_NAME" || true

# Extraemos el tag para pasarlo como variable (lo único del script "evolucionado")
TAG="${IMAGE_NAME##*:}"
echo "Detected Deployment Version: $TAG"

echo "Starting new container with SSL..."
docker run -d \
  --restart always \
  -p 443:443 \
  -v "$STAGING_DIR:/etc/nginx/certs:ro" \
  -e DEPLOYMENT_VERSION="$TAG" \
  --name landing \
  "$IMAGE_NAME"

echo "Landing deployed successfully."

# 4. Cleanup unused images
echo "Pruning unused images..."
docker image prune -a -f
