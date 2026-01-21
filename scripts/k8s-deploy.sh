#!/bin/bash

set -e

echo "Creating Kind cluster..."
sudo kind create cluster --config ./kind-config.yaml --name muchtodo-cluster

echo "Creating namespace..."
kubectl apply -f kubernetes/namespace.yaml

echo "Deploying MongoDB..."
kubectl apply -f kubernetes/mongodb

echo "Checking MongoDB status..."
kubectl get pods -n muchtodo -l app=mongodb

echo "Waiting for MongoDB to be ready..."
kubectl wait --namespace=muchtodo --for=condition=ready pod -l app=mongodb --timeout=600s || true

echo "Creating local registry..."
docker run -d --restart=always -p "5001:5000" --name "kind-registry" registry:2 || true

echo "Connecting registry to Kind network..."
docker network connect kind kind-registry || true

echo "Building and pushing application image..."
./scripts/docker-build.sh

echo "Creating secret from .env file..."
kubectl create secret generic backend-env --from-file=.env=$HOME/Downloads/month-two-assessment/Server/MuchToDo/.env \
  -n muchtodo --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying backend application..."
kubectl apply -f kubernetes/backend

echo "Checking backend status..."
kubectl get pods -n muchtodo -l app=backend

echo "Waiting for backend to be ready..."
kubectl wait --namespace=muchtodo --for=condition=ready pod -l app=backend --timeout=600s || true

echo "Installing NGINX Ingress Controller for Kind..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress controller to be initialized..."
kubectl wait --namespace=ingress-nginx --for=condition=ready pod \
  -l app.kubernetes.io/component=controller --timeout=1350s || true

echo "Verifying webhook configuration exists..."
kubectl get validatingwebhookconfiguration ingress-nginx-admission

echo "Checking Ingress controller status..."
kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller

echo "Deploying ingress..."
kubectl apply -f kubernetes/ingress.yaml

echo "Checking ingress status..."
kubectl get ingress -n muchtodo
kubectl describe ingress muchtodo-ingress -n muchtodo

echo "Deployment completed!"
echo "Access the application at: http://localhost/swagger/index.html"
