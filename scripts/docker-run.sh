#!/usr/bin/env bash
set -euo pipefail

echo "Starting services with docker compose..."
docker compose up -d

echo
echo "Current containers:"
docker ps

echo
echo "Hit http://localhost:3000/health in your browser or via curl to test the backend."