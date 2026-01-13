# container-assessment
Barakah third semester assessment
# MuchTodo Application - Containerization and Kubernetes Deployment

## Overview
This project containerizes the MuchTodo Golang backend application with MongoDB database and deploys it to Kubernetes.

## Prerequisites
- Docker & Docker Compose
- Kubernetes CLI (kubectl)
- Kind (Kubernetes in Docker)
- Go 1.25+ (for local development)

## Project Structure

```
.
├── MuchToDo/                 # Go application source code
├── kubernetes/               # Kubernetes manifests
│   ├── backend/             # Backend deployment, service, secrets
│   ├── mongodb/             # MongoDB deployment, service, PVC
│   ├── namespace.yaml       # Namespace definition
│   ├── ingress.yaml         # Ingress configuration
│   └── kind-config.yaml     # KIND cluster configuration
├── scripts/                  # Deployment automation scripts
│   ├── docker-build.sh      # Build Docker images
│   ├── docker-run.sh        # Run with docker-compose
│   ├── k8s-deploy.sh        # Deploy to Kubernetes
│   └── k8s-cleanup.sh       # Clean up Kubernetes resources
├── docker-compose.yaml       # Docker Compose configuration
├── Dockerfile               # Multi-stage Docker build
├── .dockignore            # Example environment variables
└── README.md                  # ReadMe

```

## Quick Start

### 1. Local Development with Docker Compose
```bash
# Build and run the application
./scripts/docker-run.sh

# Or manually
docker-compose up --build -d

# Check logs
docker-compose logs -f

# Stop the application
docker-compose down

# Build Docker image
./scripts/docker-build.sh

# Deploy to Kubernetes
./scripts/k8s-deploy.sh

# Clean up
./scripts/k8s-cleanup.sh

# Check Docker containers
docker-compose ps

# Check Kubernetes pods
kubectl get pods -n muchtodo

# Check Kubernetes services
kubectl get svc -n muchtodo

# Check Kubernetes ingress
kubectl get ingress -n muchtodo

# View logs
kubectl logs -f deployment/backend -n muchtodo


### **5. Evidence Collection**

For evidence folder, there are capture screenshots of:

1. **Docker Build Process**: `docker build -t muchtodo-api:latest .`
2. **Docker Compose Running**: `docker-compose ps`
3. **Application Health Check**: `curl http://localhost:8080/health`
4. **Kind Cluster Creation**: `kind create cluster`
5. **Kubernetes Pods Running**: `kubectl get pods -n muchtodo`
6. **Services Status**: `kubectl get svc -n muchtodo`
7. **Ingress Status**: `kubectl get ingress -n muchtodo`
8. **Application Access**: Browser showing API response


You can now fork the repository and implement this solution step by step. Let me know if you need help with any specific part!