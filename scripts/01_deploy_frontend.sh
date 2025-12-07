#!/bin/bash

DOMAIN="agevega.com"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
IMAGE_NAME="frontend:latest" # Update this if using a different image tag/name

# 1. Check for certificates
if ! sudo test -d "$CERT_PATH"; then
    echo "Error: Certificates not found at $CERT_PATH"
    echo "Please run scripts/00_generate_cert.sh first."
    exit 1
fi

# 2. Re-deploy container
echo "Stopping old container..."
docker stop frontend || true
docker rm frontend || true

echo "Starting new container with SSL..."
docker run -d \
  --restart always \
  -p 80:80 -p 443:443 \
  -v "$CERT_PATH:/etc/nginx/certs:ro" \
  --name frontend \
  "$IMAGE_NAME"

echo "Frontend deployed successfully."
