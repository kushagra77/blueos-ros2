#!/bin/bash
echo " CHECK EXTENSION SETTINGS AND COPY THEM OVER BEFORE CHANGING EXTENSION "
exit 0
# check for version argument
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

USERNAME="krushion"
IMAGE_NAME="blueos-ros2-manta"

# Log in to Docker Hub
docker login

# Build and Push with optimizations
docker buildx build --platform linux/arm64 --network=host --progress=plain \
  -t "$USERNAME/$IMAGE_NAME:$1" \
  -t "$USERNAME/$IMAGE_NAME:latest" \
  --output type=image,compression=zstd,push=true,provenance=false,sbom=false \
  .