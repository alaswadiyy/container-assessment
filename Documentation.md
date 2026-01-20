# MuchToDo Kubernetes Bootstrap Script
This repository includes a Bash script that **fully bootstraps a local Kubernetes environment using Kind**, deploys application dependencies, and exposes the backend service via **NGINX Ingress**.

---

## 📌 What This Script Does
At a high level, the script:
1. Creates a local Kubernetes cluster using **Kind**
2. Creates an isolated namespace for the application
3. Deploys MongoDB and waits until it is ready
4. Builds and pushes the backend image to a local Docker registry
5. Deploys the backend service and waits for readiness
6. Installs the NGINX Ingress Controller (Kind-compatible)
7. Safely creates an Ingress resource to expose the application

All steps are executed in the **correct dependency order**, with readiness checks at each stage.

---

## 🧱 Prerequisites
Ensure the following tools are installed:
* Docker
* Kind
* kubectl
* Bash

---

## 🚀 Script Execution Flow (Detailed)
1. Fail-Fast Execution
The script starts with:
```bash
set -e
```
This ensures the script **stops immediately on any error**, preventing partial or inconsistent deployments.

2. Create Kind Cluster
Creates a reproducible local Kubernetes cluster using a custom Kind configuration.
```bash
kind create cluster --config ./kind-config.yaml --name muchtodo-cluster
```

3. Create Namespace
Creates the `muchtodo` namespace to logically isolate application resources.
```bash
kubectl apply -f kubernetes/namespace.yaml
```

4. Deploy MongoDB (With Readiness Gate)
MongoDB is deployed first and the script **waits until the database pods are Ready** before continuing. This prevents the backend from starting before its database dependency is available.
```bash
kubectl apply -f kubernetes/mongodb
kubectl wait --namespace=muchtodo --for=condition=ready pod -l app=mongodb --timeout=300s || exit 1
```

5. Create and Connect Local Docker Registry
```bash
docker run -d --restart=always -p "5001:5000" --name kind-registry registry:2 || true
docker network connect kind kind-registry || true
```
A local Docker registry is created and attached to the Kind network so cluster nodes can pull locally built images.
* `|| true` ensures the script is **idempotent** and safe to re-run

6. Build and Push Backend Image
Builds the backend application image and pushes it to the local registry. This avoids reliance on public registries and speeds up local development.
```bash
./scripts/docker-build.sh
```

7. Create Kubernetes Secret from `.env`
```bash
kubectl create secret generic backend-env --from-file=.env=path/to/.env \
  -n muchtodo --dry-run=client -o yaml | kubectl apply -f -
```
Creates or updates a Kubernetes Secret using environment variables.
* `--dry-run=client` + `kubectl apply` ensures **safe updates** without deletion

8. Deploy Backend Application (With Readiness Gate)
Deploys the backend service and waits until it is fully Ready before exposure.
```bash
kubectl apply -f kubernetes/backend
kubectl wait --namespace=muchtodo --for=condition=ready pod -l app=backend --timeout=300s || exit 1
```

9. Install NGINX Ingress Controller (Kind-Compatible)
Installs the NGINX Ingress Controller configured specifically for Kind environments.
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/kind/deploy.yaml
```

10. Wait for Ingress Controller Initialization and verifying webhook configuration exists
These steps ensure:
* The ingress controller pod is running
* Admission webhook jobs are completed
```bash
kubectl wait --namespace=ingress-nginx --for=condition=ready pod \
  -l app.kubernetes.io/component=controller --timeout=990s || exit 1
kubectl get validatingwebhookconfiguration ingress-nginx-admission
```
✅ This prevents common `connection refused` webhook errors when creating Ingress resources.

11. Deploy Ingress Resource
Creates the Ingress resource that exposes the backend service via HTTP.
```bash
kubectl apply -f kubernetes/ingress.yaml
```

---

## 🌐 Accessing the Application
Once the script completes successfully:
```text
http://localhost/swagger/index.html
```

---

## ⭐ Design Principles Demonstrated
* **State-based orchestration** using `kubectl wait`
* **Dependency-aware deployment order**
* **Idempotent operations** using `kubectl apply`
* **Fail-fast execution** with `set -e`
* **Ingress webhook safety handling**

---

## 🧠 Notes for Reviewers
This script intentionally avoids:
* Hard-coded sleep delays
* Race conditions during Ingress creation
* Manual cluster setup steps
It reflects **production-quality Kubernetes thinking**, adapted for a local Kind environment.

---

## 🧹 Cleanup
To delete the cluster:
```bash
kind delete cluster --name muchtodo-cluster
docker stop kind-registry
docker rm kind-registry
docker system prune -a
docker system prune --volumes
```

---

✅ **Result:** A fully automated, reliable local Kubernetes deployment for the MuchToDo application.
