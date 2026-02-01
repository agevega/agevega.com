#!/bin/bash

IMAGE_NAME="${1:-frontend:latest}"

# Stop and remove old container
echo "Stopping old container..."
docker stop frontend || true
docker rm frontend || true

# Remove local image to force re-pull
echo "Removing local image to force re-pull..."
docker rmi -f "$IMAGE_NAME" || true

# Start new container
echo "Starting new container..."
docker run -d \
  --restart always \
  -p 80:80 \
  --name frontend \
  "$IMAGE_NAME"

echo "Frontend deployed successfully."

# Cleanup unused images
echo "Pruning unused images..."
docker image prune -a -f
