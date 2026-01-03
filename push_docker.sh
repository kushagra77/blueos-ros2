#!/bin/bash

# check for version argument
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

docker login
docker buildx build --platform linux/arm64 --network=host --progress=plain \
  -t "krushion/blueos-ros2-manta:$1" --push .