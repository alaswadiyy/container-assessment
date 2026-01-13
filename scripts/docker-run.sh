#!/bin/bash

# Start the application with docker-compose
echo "Starting MuchTodo application with Docker Compose..."
docker-compose up --build -d

echo "Application is starting..."
echo "Backend API will be available at: http://localhost:8080"
echo "MongoDB will be available at: localhost:27017"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"