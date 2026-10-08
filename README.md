# Wanderlust 🌍✈️

[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm 3](https://img.shields.io/badge/Helm_3-Packaged-0F1689?logo=helm&logoColor=white)](https://helm.sh/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF6B48?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Trivy](https://img.shields.io/badge/Trivy-Secured-1B4958?logo=aquasec&logoColor=white)](https://trivy.dev/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)

> **The Ultimate Full-Stack Travel Blog Application with Enterprise DevOps & GitOps Lifecycle**

![Preview Image](https://github.com/krishnaacharyaa/wanderlust/assets/116620586/17ba9da6-225f-481d-87c0-5d5a010a9538)

---

## 🚀 DevOps & GitOps Highlights

This repository is equipped with a complete, production-ready DevOps and GitOps delivery pipeline:

- 🐳 **Multi-Stage Dockerization:** Hardened Dockerfiles for React (Vite/Nginx) and Node.js Express API.
- 📦 **Docker Compose Stack:** 4-tier orchestration (`frontend`, `backend`, `mongo`, `redis`) with healthcheck dependencies.
- 🛡️ **DevSecOps with Trivy:** Automated vulnerability scanning across filesystem dependencies, container images, and Kubernetes IaC.
- 🏗️ **Enterprise Jenkins Pipeline:** Declarative CI/CD pipeline covering build, security scanning, image publishing, and deployment.
- ☸️ **Kubernetes Manifests (Kustomize):** Production manifests with rolling updates, resource limits, and Horizontal Pod Autoscalers (HPA).
- ⛵ **Helm 3 Charts:** Fully parameterized chart under `helm/wonderlust/`.
- 📊 **Komodor Helm Dashboard:** Web visualization interface on port `8085`.
- 🐙 **ArgoCD Continuous Delivery:** Automated GitOps reconciliation with drift detection and self-healing.

📖 **For detailed operational walkthroughs and architecture explanations, see [DEVOPS_GUIDE.md](DEVOPS_GUIDE.md).**

---

## ⚡ Quick Start with Docker Compose

Launch the entire stack (Frontend, Backend, MongoDB, Redis) locally in seconds:

```bash
# Clone the repository
git clone https://github.com/mukeshchaudhary14/Wonderlust-.git
cd Wonderlust

# Launch all 4 services
docker compose up -d --build
```

### Access Services:
- **Frontend Web UI:** [http://localhost:3000](http://localhost:3000)
- **Backend API:** [http://localhost:5000](http://localhost:5000)
- **MongoDB:** `localhost:27017`
- **Redis Cache:** `localhost:6379`

---

## ☸️ Kubernetes & Helm Deployment

### Deploy via Kustomize:
```bash
./scripts/k8s-deploy.sh
```

### Deploy via Helm:
```bash
./scripts/helm-deploy.sh wonderlust wonderlust
```

### Launch Komodor Helm Dashboard (Port 8085):
```bash
./scripts/helm-dashboard.sh
```

---

## 🐙 GitOps with ArgoCD

Install the ArgoCD controller and link the repository for automated GitOps reconciliation:

```bash
./argocd/install-argocd.sh
```

ArgoCD UI will be accessible at: **https://localhost:8443**

---

## 🛡️ Security Vulnerability Audit (Trivy)

Run full filesystem, container, and IaC vulnerability audits:

```bash
./scripts/trivy-scan.sh
```

Audit reports are generated in `trivy-reports/`.

---

## 🎯 Original Project Goals & Features

At its core, this project embodies two important aims:
1. **Start Your Open Source Journey**: Kickstart your open-source journey with practical Git workflows and a solid grip on the MERN stack.
2. **React Mastery**: Master React fundamentals and advanced patterns, from form validation to performance optimization.

### Key Features:
- **Featured Posts:** Highlight top travel stories and destinations on the homepage.
- **Intuitive Interface:** Effortless navigation with responsive Tailwind CSS design.
- **Category Discovery:** Explore diverse travel experiences categorized by travel, nature, city, adventure, and beaches.
