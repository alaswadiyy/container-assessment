#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="muchtodo"
CLUSTER_NAME="muchtodo"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${ROOT_DIR}"

echo "Deleting Kubernetes resources in namespace '${NAMESPACE}'..."

kubectl delete -n "${NAMESPACE}" -f kubernetes/ingress.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/backend/backend-service.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/backend/backend-deployment.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/backend/backend-secret.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/backend/backend-configmap.yaml --ignore-not-found

kubectl delete -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-service.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-deployment.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-pvc.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-secret.yaml --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f kubernetes/mongodb/mongodb-configmap.yaml --ignore-not-found

kubectl delete -f kubernetes/namespace.yaml --ignore-not-found

echo
echo "Kubernetes resources deleted."

echo "If you also want to delete the kind cluster, run:"
echo "  kind delete cluster --name ${CLUSTER_NAME}"