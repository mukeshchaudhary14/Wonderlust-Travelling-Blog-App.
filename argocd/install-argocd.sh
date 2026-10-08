#!/usr/bin/env bash
# =========================================================================
# ArgoCD GitOps Controller Installation & Access Script for Wonderlust
# Exposes ArgoCD Web UI on Port 8443 (avoids port collisions with Jenkins 8080)
# =========================================================================

set -eo pipefail

ARGOCD_PORT=8443

echo "=========================================================="
echo "🐙 Installing ArgoCD GitOps Controller in Kubernetes..."
echo "=========================================================="

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Applying ArgoCD core manifests..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD Server pod to become ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

echo "🚀 Registering Wonderlust GitOps Application with ArgoCD..."
kubectl apply -f "$(dirname "${BASH_SOURCE[0]}")/application.yaml"

echo "🔑 Retrieving initial ArgoCD admin password..."
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "Password already reset or not found")

echo ""
echo "=========================================================="
echo "🎉 ArgoCD is Ready!"
echo "🌐 UI URL:  https://localhost:${ARGOCD_PORT}"
echo "👤 User:    admin"
echo "🔑 Password: ${ADMIN_PASSWORD}"
echo "=========================================================="
echo ""
echo "Starting port-forward to https://localhost:${ARGOCD_PORT}..."
kubectl port-forward svc/argocd-server -n argocd "${ARGOCD_PORT}:443"
