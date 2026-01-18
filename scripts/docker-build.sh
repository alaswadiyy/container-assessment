#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="muchtodo-backend"
IMAGE_TAG="latest"

echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
echo "Build complete."