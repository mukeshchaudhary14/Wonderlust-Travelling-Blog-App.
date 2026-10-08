#!/usr/bin/env bash
# =========================================================================
# Deploy Wonderlust via Helm 3 Chart
# =========================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

RELEASE_NAME="${1:-wonderlust}"
NAMESPACE="${2:-wonderlust}"

echo "=========================================================="
echo "☸️  Deploying Wonderlust via Helm Chart"
echo "📦 Release Name: ${RELEASE_NAME}"
echo "🏷️ Namespace:    ${NAMESPACE}"
echo "=========================================================="

cd "${ROOT_DIR}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

if command -v helm >/dev/null 2>&1; then
  helm upgrade --install "${RELEASE_NAME}" helm/wonderlust \
    --namespace "${NAMESPACE}" \
    --values helm/wonderlust/values.yaml
else
  echo "🐳 Using Dockerized Helm to deploy..."
  docker run --rm \
    --net=host \
    -v "${HOME}/.kube/config:/root/.kube/config:ro" \
    -v "${ROOT_DIR}:/apps" \
    alpine/helm:latest upgrade --install "${RELEASE_NAME}" /apps/helm/wonderlust \
      --namespace "${NAMESPACE}" \
      --values /apps/helm/wonderlust/values.yaml
fi

echo ""
echo "✅ Helm deployment initiated successfully!"
kubectl get pods -n "${NAMESPACE}"
