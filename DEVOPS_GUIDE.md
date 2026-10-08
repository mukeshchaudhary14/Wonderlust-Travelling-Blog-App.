# Wonderlust Application - Complete End-to-End DevOps & GitOps Guide

This guide covers the complete DevOps and GitOps lifecycle for the **Wonderlust** full-stack travel blogging application — structured according to enterprise standards. It includes multi-stage Docker containerization, local multi-service orchestration with Docker Compose, automated Trivy security vulnerability scanning, declarative Jenkins CI/CD pipelines, Kubernetes manifests with Kustomize, parameterized Helm 3 charts, Komodor Helm Dashboard visualization, and GitOps continuous delivery powered by ArgoCD.

---

## 📑 Table of Contents
1. [Architecture Overview](#1-architecture-overview)
2. [Multi-Service Application Stack](#2-multi-service-application-stack)
3. [Port Allocation & Conflict Prevention](#3-port-allocation--conflict-prevention)
4. [Docker & Multi-Stage Containerization](#4-docker--multi-stage-containerization)
5. [Docker Compose Local Orchestration](#5-docker-compose-local-orchestration)
6. [Trivy DevSecOps & Vulnerability Scanning](#6-trivy-devsecops--vulnerability-scanning)
7. [Jenkins CI/CD Declarative Pipeline](#7-jenkins-cicd-declarative-pipeline)
8. [Kubernetes Manifests & Kustomize (k8s/)](#8-kubernetes-manifests--kustomize-k8s)
9. [Helm 3 Packaging & Charts (helm/wonderlust/)](#9-helm-3-packaging--charts-helmwonderlust)
10. [Komodor Helm Dashboard Integration](#10-komodor-helm-dashboard-integration)
11. [ArgoCD GitOps Continuous Delivery](#11-argocd-gitops-continuous-delivery)
12. [Operational Verification & Troubleshooting](#12-operational-verification--troubleshooting)

---

## 1. Architecture Overview

```
+---------------------------------------------------------------------------------------------------------+
|                                    DEV / SOURCE CODE REPOSITORY                                         |
|                               (GitHub: mukeshchaudhary14/Wonderlust-)                                        |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v (Push / Webhook)
+---------------------------------------------------------------------------------------------------------+
|                                        JENKINS CI/CD PIPELINE                                           |
|  1. Checkout -> 2. Trivy FS Scan -> 3. Docker Build (FE & BE) -> 4. Trivy Image Scan                   |
|  5. Push to Docker Hub -> 6. Helm Lint & Validate -> 7. Continuous Deployment                           |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|                                        DOCKER HUB REGISTRY                                              |
|      - mukeshchaudhary14/wonderlust-backend:latest                                                      |
|      - mukeshchaudhary14/wonderlust-frontend:latest                                                     |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|                                        GITOPS CONTROLLER (ARGOCD)                                       |
|                  Tracks Git Repository (helm/wonderlust) & Reconciles Cluster State                     |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|                                          KUBERNETES CLUSTER                                             |
|  - Namespace: wonderlust                                                                                |
|  - Ingress Controller (NGINX)                                                                           |
|      * /api -> Backend Service (ClusterIP:5000) -> wonderlust-backend Pods (Autoscaled via HPA)         |
|      * /    -> Frontend Service (ClusterIP:80)   -> wonderlust-frontend Pods (Autoscaled via HPA)        |
|  - Databases & Caches:                                                                                  |
|      * MongoDB (Port 27017, Persistent Volume)                                                          |
|      * Redis   (Port 6379, In-memory Cache)                                                             |
|  - Visualization:                                                                                       |
|      * Komodor Helm Dashboard (Port 8085)                                                               |
+---------------------------------------------------------------------------------------------------------+
```

---

## 2. Multi-Service Application Stack

| Component | Technology | Role & Functionality |
| :--- | :--- | :--- |
| **Frontend** | React 18, Vite, Tailwind CSS, Axios | Single Page Application (SPA) client interface |
| **Frontend Server** | Nginx Alpine (Reverse Proxy) | Serves production assets, proxies `/api` to backend |
| **Backend API** | Node.js 20, Express, TypeScript | RESTful API for auth, blogs, comments, users |
| **Database** | MongoDB 7.0 | Document store for users, posts, sessions |
| **Cache** | Redis 7.0 Alpine | In-memory cache for API queries and session caching |

---

## 3. Port Allocation & Conflict Prevention

To prevent host port collisions across concurrent enterprise workloads:

| Port | Service | Environment | Notes |
| :--- | :--- | :--- | :--- |
| **8080** | Jenkins Master | Host / CI Server | Reserved for Jenkins CI server |
| **8082** | Petstore Application | Host / Container | Reserved for Petstore app |
| **3000** | Wonderlust Frontend | Docker Compose / Host | Mapped to container port 80 via Nginx |
| **5000** | Wonderlust Backend | Docker Compose / Host | Express API server |
| **27017** | MongoDB | Docker Compose / Cluster | Primary document store |
| **6379** | Redis | Docker Compose / Cluster | Cache server |
| **8085** | Komodor Helm Dashboard | Host / Web UI | Configured on 8085 to prevent collision |
| **8443** | ArgoCD Web UI | Kubernetes Port-Forward | ArgoCD GitOps dashboard |

---

## 4. Docker & Multi-Stage Containerization

Both services are built using multi-stage Dockerfiles to minimize image attack surfaces and exclude build tooling from final production images.

### Backend (`backend/Dockerfile`)
- **Stage 1 (Builder):** Uses `node:20-alpine`, installs full dependencies and compiles TypeScript (`tsc`) to `dist/`.
- **Stage 2 (Runner):** Uses `node:20-alpine`, installs production dependencies only (`npm install --omit=dev`), runs under unprivileged non-root user `node` (UID 1000), includes `dumb-init` for POSIX signal handling, and incorporates healthcheck on `http://localhost:5000/`.

### Frontend (`frontend/Dockerfile`)
- **Stage 1 (Builder):** Uses `node:20-alpine`, compiles Vite static assets to `dist/`.
- **Stage 2 (Runner):** Uses `nginx:alpine`, serves minified assets with Gzip compression and security headers (`X-Frame-Options`, `X-Content-Type-Options`), includes SPA fallback (`try_files $uri /index.html;`) and reverse proxying for `/api/` endpoints to the backend container.

---

## 5. Docker Compose Local Orchestration

Launch all 4 services with a single command:

```bash
docker compose up -d --build
```

### Healthcheck Dependency Chain:
1. `mongo` starts and verifies readiness via `mongosh ping`.
2. `redis` starts and verifies readiness via `redis-cli ping`.
3. `backend` waits for `mongo` and `redis` to become healthy before booting.
4. `frontend` waits for `backend` to become healthy before accepting traffic.

### Managing Containers:
```bash
# Check status of running containers
docker compose ps

# View real-time logs
docker compose logs -f backend

# Stop all services and retain volume data
docker compose down

# Stop and delete volumes
docker compose down -v
```

---

## 6. Trivy DevSecOps & Vulnerability Scanning

The project includes pre-configured Trivy security audits targeting:
1. **Source Code & Dependencies (SAST / CVEs):** Scans npm dependencies in both frontend and backend.
2. **Container Images:** Scans backend and frontend Docker images for OS and package vulnerabilities.
3. **Infrastructure as Code (IaC):** Scans Kubernetes manifests and Helm templates for misconfigurations.

### Run Scan via Helper Script:
```bash
./scripts/trivy-scan.sh
```

All reports are stored in `trivy-reports/`:
- `trivy-fs-report.txt`
- `trivy-backend-image-report.txt`
- `trivy-frontend-image-report.txt`
- `trivy-iac-report.txt`

---

## 7. Jenkins CI/CD Declarative Pipeline

The `Jenkinsfile` defines an automated pipeline with the following stages:

```
[Checkout] ➡️ [Trivy FS Scan] ➡️ [Docker Build] ➡️ [Trivy Image Scan] ➡️ [Docker Hub Push] ➡️ [Helm Validate] ➡️ [K8s Deploy]
```

### Pipeline Parameters:
- `PUSH_IMAGES`: If enabled, pushes images to Docker Hub.
- `IMAGE_TAG`: Docker tag (defaults to `latest` or git commit SHA).
- `DEPLOY_K8S`: Deploys Helm chart to Kubernetes cluster.
- `K8S_NAMESPACE`: Target namespace (defaults to `wonderlust`).
- `HELM_RELEASE`: Helm release name (defaults to `wonderlust`).

---

## 8. Kubernetes Manifests & Kustomize (`k8s/`)

Declarative Kubernetes manifests are located in `k8s/`:

```
k8s/
├── namespace.yaml             # Creates 'wonderlust' namespace
├── configmap.yaml             # Application configuration
├── secret.yaml                # Application secrets (JWT secret, OAuth credentials)
├── mongodb.yaml               # MongoDB Deployment, Service (27017), PVC (5Gi)
├── redis.yaml                 # Redis Deployment, Service (6379)
├── backend-deployment.yaml    # Backend API (2 Replicas, probes, non-root user)
├── backend-service.yaml       # Backend ClusterIP Service (Port 5000)
├── frontend-deployment.yaml   # Frontend Nginx (2 Replicas, probes)
├── frontend-service.yaml      # Frontend ClusterIP Service (Port 80)
├── ingress.yaml               # Ingress routing for frontend (/) and backend (/api)
├── hpa.yaml                   # Horizontal Pod Autoscalers (2-10 replicas based on CPU/Memory)
└── kustomization.yaml         # Kustomize manifest bundle
```

### Deploying via Kustomize:
```bash
kubectl apply -k k8s/
```

---

## 9. Helm 3 Packaging & Charts (`helm/wonderlust/`)

The application is packaged as a Helm 3 chart in `helm/wonderlust/`:

### Chart Structure:
```
helm/wonderlust/
├── Chart.yaml                 # Metadata (Version 1.0.0)
├── values.yaml                # Parameterized configurations
└── templates/
    ├── _helpers.tpl           # Label and naming macros
    ├── configmap.yaml         # ConfigMap template
    ├── secrets.yaml           # Secret template
    ├── mongodb.yaml           # MongoDB workload and PVC template
    ├── redis.yaml             # Redis workload template
    ├── backend-deployment.yaml# Backend Deployment template
    ├── backend-service.yaml   # Backend Service template
    ├── frontend-deployment.yaml# Frontend Deployment template
    ├── frontend-service.yaml  # Frontend Service template
    ├── ingress.yaml           # Ingress controller routing template
    ├── hpa.yaml               # HorizontalPodAutoscaler template
    └── NOTES.txt              # Post-installation instructions
```

### Deploying via Helm:
```bash
./scripts/helm-deploy.sh wonderlust wonderlust
```

---

## 10. Komodor Helm Dashboard Integration

Komodor Helm Dashboard provides a visual GUI for monitoring Helm releases, revisions, diffs, and pod states.

### Run Dashboard on Port 8085:
```bash
./scripts/helm-dashboard.sh
```

Open: **`http://localhost:8085`** in your browser.

---

## 11. ArgoCD GitOps Continuous Delivery

ArgoCD continuously monitors the Git repository and reconciles any drift between the Git repository and the cluster.

### 1. Install ArgoCD & Register Application:
```bash
./argocd/install-argocd.sh
```

### 2. Access ArgoCD UI:
- **URL:** `https://localhost:8443`
- **Username:** `admin`
- **Password:** Automatically printed by the script or retrieved with:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

---

## 12. Operational Verification & Troubleshooting

### Useful Inspection Commands:
```bash
# Check all resources in the wonderlust namespace
kubectl get all -n wonderlust

# View backend application logs
kubectl logs -n wonderlust -l app.kubernetes.io/name=wonderlust-backend -f

# Verify HPA autoscaling status
kubectl get hpa -n wonderlust

# Port forward frontend for local testing
kubectl port-forward svc/wonderlust-frontend 3000:80 -n wonderlust

# Port forward backend API
kubectl port-forward svc/wonderlust-backend 5000:5000 -n wonderlust
```
