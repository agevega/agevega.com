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

# Start new container
echo "Starting new container..."
docker run -d \
  --restart always \
  -p 80:80 \
  -e DEPLOYMENT_VERSION="$TAG" \
  --name frontend \
  "$IMAGE_NAME"

echo "Frontend deployed successfully."

# Cleanup unused images
echo "Pruning unused images..."
docker image prune -a -f
