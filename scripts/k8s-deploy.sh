#!/usr/bin/env bash
# =========================================================================
# Deploy Wonderlust to Kubernetes using Kustomize
# =========================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo "☸️  Deploying Wonderlust to Kubernetes (k8s/)"
echo "=========================================================="

cd "${ROOT_DIR}"
kubectl apply -k k8s/

echo ""
echo "⏳ Waiting for deployments to roll out..."
kubectl rollout status deployment/wonderlust-backend -n wonderlust --timeout=180s || true
kubectl rollout status deployment/wonderlust-frontend -n wonderlust --timeout=180s || true

echo ""
echo "📊 Pod Status:"
kubectl get pods -n wonderlust

echo ""
echo "🌐 Service Endpoints:"
kubectl get svc -n wonderlust
