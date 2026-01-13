#!/bin/bash

echo "Cleaning up Kubernetes resources..."
kubectl delete -f kubernetes/ingress.yaml
kubectl delete -f kubernetes/backend/
kubectl delete -f kubernetes/mongodb/
kubectl delete -f kubernetes/namespace.yaml

echo "Deleting Kind cluster..."
kind delete cluster --name muchtodo-cluster

echo "Cleanup completed!"