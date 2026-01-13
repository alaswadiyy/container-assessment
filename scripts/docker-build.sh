#!/bin/bash

# Build Docker image
echo "Building Docker image..."
docker build -t muchtodo-api:latest .

# Tag for registry (optional)
# docker tag muchtodo-api:latest your-registry/muchtodo-api:latest

echo "Docker build completed successfully!"