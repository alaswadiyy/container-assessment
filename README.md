# MuchTodo Application Containerization
This project containerizes the MuchTodo Golang backend application and deploys it to Kubernetes.

## Prerequisites
- Docker
- Docker Compose
- Kubernetes CLI (kubectl)
- Kind (Kubernetes in Docker)
- Go 1.25+

---

## Quick Start
Clone the repository
```bash
git clone https://github.com/alaswadiyy/container-assessment.git
```

---

## Docker Development
1. copy `.env.example` to `.env`, then update the content accordingly
   ```bash
   cp MuchToDo/.env.example MuchToDo/.env
   ```
2. Run: `./scripts/docker-build.sh`
   ![docker_build](./evidence/docker-build.png)
3. Run: `./scripts/docker-run.sh`
   ![docker_compose](./evidence/docker-compose.png)
4. Access: http://localhost:8080/swagger/index.html
   ![docker_compose_app_response](./evidence/docker-compose-app-response.png)

---

## Kubernetes Deployment
1. Ensure `step 1` from `Docker Developement` above has been done, if not repeat the step
2. Update the env path in `k8s-deploy.sh`
   ```bash
   kubectl create secret generic backend-env --from-file=.env=<path-to-your-env> \
      -n muchtodo --dry-run=client -o yaml | kubectl apply -f -
   ```
3. Run: `./scripts/k8s-deploy.sh`
   - Kind cluster creation
   ![kind_cluster_creation](./evidence/kind-cluster-creation.png)
   - Kubernetes deployments running
   ![k8s_deploy_start](./evidence/k8s-deployments-running-1.png)
   ![k8s_deploy_midway](./evidence/k8s-deployments-running-2.png)
   ![k8s_deploy_finish](./evidence/k8s-deployments-running-3.png)
4. Application accessible through a NodePort Service type to the host or Kubernetes ingress
   ![k8s_deploy_app_response](./evidence/application-accessible.png)
5. Kubectl commands showing pod status, services, and ingress
   ![kubectl_pod_status_services_ingress.png](./evidence/kubectl-pod-status-services-ingress.png)

For detailed script flow execution read [Documentation](./Documentation.md)

---

## Cleanup
1. Shut down the entire Docker Compose stack and deletes its data volumes:
   `sudo docker compose down -v`
2. Clean up unused Docker resources system-wide:
   `sudo docker system prune -af`
3. Kubernetes:
   `./scripts/k8s-cleanup.sh`
   ![k8s_cleanup_process_start](./evidence/k8s-cleanup-process-1.png)
   ![k8s_cleanup_process_finish](./evidence/k8s-cleanup-process-2.png)

---

## Architecture
- Backend: Golang API on port 8080
- Database: MongoDB with persistence
- Kubernetes: Namespace-scoped deployment
- Ingress: Nginx ingress controller

---

## Health Checks
- Backend: http://localhost:8080/health
- MongoDB: Internal health probes

---

## Environment Variables
See `docker-compose.yml`, Kubernetes configs and secrets for environment configuration.
