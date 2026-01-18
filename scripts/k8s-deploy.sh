#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="muchtodo"
CLUSTER_NAME="muchtodo"
IMAGE_NAME="muchtodo-backend:latest"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Using project root: ${ROOT_DIR}"

cd "${ROOT_DIR}"

echo "Ensuring kind cluster '${CLUSTER_NAME}' exists..."
if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}" --config kind-cluster.yaml
else
  echo "Kind cluster '${CLUSTER_NAME}' already exists."
fi

echo
echo "Building Docker image..."
docker build -t "${IMAGE_NAME}" .

echo
echo "Loading image into kind cluster..."
kind load docker-image "${IMAGE_NAME}" --name "${CLUSTER_NAME}"

echo
echo "Applying Kubernetes manifests..."

kubectl apply -f kubernetes/namespace.yaml

kubectl apply -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-configmap.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-secret.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-pvc.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-deployment.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-service.yaml

kubectl apply -n "${NAMESPACE}" -f kubernetes/backend/backend-configmap.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/backend/backend-secret.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/backend/backend-deployment.yaml
kubectl apply -n "${NAMESPACE}" -f kubernetes/backend/backend-service.yaml

kubectl apply -n "${NAMESPACE}" -f kubernetes/ingress.yaml

echo
echo "Resources in namespace ${NAMESPACE}:"
kubectl get pods -n "${NAMESPACE}"
kubectl get svc -n "${NAMESPACE}"
kubectl get ingress -n "${NAMESPACE}"

echo
echo "You can now test the app via NodePort:"
echo "  curl http://localhost:30080/health"