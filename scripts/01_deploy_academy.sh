#!/bin/bash
set -euo pipefail

# Cert lives at /etc/letsencrypt/live/agevega.com/ (multi-SAN cert covers
# both landing and academy domains). Container will serve dev.academy.agevega.com.
DOMAIN="agevega.com"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
IMAGE_NAME="${1:-academy:latest}" # Use first argument as image name, default to academy:latest

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
# Shared staging dir with landing — both containers mount read-only, no race.
STAGING_DIR="$HOME/agevega_certs"
mkdir -p "$STAGING_DIR"

echo "Staging certificates..."
sudo cp -L "$CERT_PATH/fullchain.pem" "$STAGING_DIR/fullchain.pem"
sudo cp -L "$CERT_PATH/privkey.pem" "$STAGING_DIR/privkey.pem"
sudo chown -R "$(whoami):$(whoami)" "$STAGING_DIR"

# 3. Re-deploy container
echo "Stopping old container..."
docker stop academy || true
docker rm academy || true

echo "Removing local image to force re-pull..."
docker rmi -f "$IMAGE_NAME" || true

TAG="${IMAGE_NAME##*:}"
echo "Detected Deployment Version: $TAG"

# Host port 8443 → container port 443 (nginx inside the container terminates TLS on 443).
# CloudFront academy distribution has origin custom_origin_config.https_port = 8443.
echo "Starting new container with SSL..."
docker run -d \
  --restart always \
  -p 8443:443 \
  -v "$STAGING_DIR:/etc/nginx/certs:ro" \
  -e DEPLOYMENT_VERSION="$TAG" \
  --name academy \
  "$IMAGE_NAME"

echo "Academy deployed successfully."

# 4. Cleanup unused images
echo "Pruning unused images..."
docker image prune -a -f
