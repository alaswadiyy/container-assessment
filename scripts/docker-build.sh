#!/bin/bash

set -e

echo "Building Docker image..."
sudo docker build -t muchtodo-backend:latest .

echo "Making sure the local Docker registry is running..."
if [ "$(sudo docker ps -q -f name=registry)" ]; then
    echo "Local Docker registry is already running."
else
    echo "Starting local Docker registry..."
    sudo docker run -d -p 5001:5000 --restart=always --name registry registry:2
fi

echo "Tagging image for local registry..."
sudo docker tag muchtodo-backend:latest localhost:5001/muchtodo-backend:latest

echo "Pushing to local registry..."
sudo docker push localhost:5001/muchtodo-backend:latest

echo "Build completed successfully!"
