#!/bin/bash

set -e

echo "Starting MuchTodo application with Docker Compose..."
sudo docker compose up -d

echo "Waiting for services to start..."
sleep 10

echo "Checking service status..."
sudo docker compose ps

echo "Application should be available at http://localhost:8080"
