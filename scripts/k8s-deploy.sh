#!/bin/bash

# Create Kind cluster if not exists
if ! kind get clusters | grep -q muchtodo-cluster; then
    echo "Creating Kind cluster..."
    kind create cluster --name muchtodo-cluster --config kind-config.yaml
fi

# Set kubectl context
kubectl config use-context kind-muchtodo-cluster

# Create namespace
echo "Creating namespace..."
kubectl apply -f kubernetes/namespace.yaml

# Deploy MongoDB
echo "Deploying MongoDB..."
kubectl apply -f kubernetes/mongodb/mongodb-secret.yaml
kubectl apply -f kubernetes/mongodb/mongodb-configmap.yaml
kubectl apply -f kubernetes/mongodb/mongodb-pvc.yaml
kubectl apply -f kubernetes/mongodb/mongodb-deployment.yaml
kubectl apply -f kubernetes/mongodb/mongodb-service.yaml

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
kubectl wait --namespace muchtodo --for=condition=ready pod -l app=mongodb --timeout=120s

# Deploy Backend
echo "Deploying Backend..."
# Load image to Kind cluster
kind load docker-image muchtodo-api:latest --name muchtodo-cluster

kubectl apply -f kubernetes/backend/backend-secret.yaml
kubectl apply -f kubernetes/backend/backend-configmap.yaml
kubectl apply -f kubernetes/backend/backend-deployment.yaml
kubectl apply -f kubernetes/backend/backend-service.yaml

# Deploy Ingress
echo "Deploying Ingress..."
kubectl apply -f kubernetes/ingress.yaml

# Wait for Backend to be ready
echo "Waiting for Backend to be ready..."
kubectl wait --namespace muchtodo --for=condition=ready pod -l app=backend --timeout=120s

echo ""
echo "Deployment completed successfully!"
echo ""
echo "Access the application via:"
echo "1. NodePort: http://localhost:30080"
echo "2. Port forward: kubectl port-forward svc/backend-service 8080:8080 -n muchtodo"
echo ""
echo "Check pod status: kubectl get pods -n muchtodo"
echo "Check services: kubectl get svc -n muchtodo"
echo "Check ingress: kubectl get ingress -n muchtodo"