#!/usr/bin/env bash
# =========================================================================
# Komodor Helm Dashboard Launcher for Wonderlust
# Serves Helm Dashboard on Port 8085 (avoids Jenkins 8080 & Petstore 8082)
# =========================================================================

set -eo pipefail

PORT=8085
echo "=========================================================="
echo "☸️  Launching Komodor Helm Dashboard on http://localhost:${PORT}"
echo "=========================================================="

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "⚠️ Warning: No active Kubernetes cluster connection detected."
  echo "👉 Start a local cluster (e.g., kind create cluster --name wonderlust) or check your kubeconfig."
fi

if docker --version >/dev/null 2>&1; then
  echo "🐳 Running Komodor Helm Dashboard via Docker..."
  docker run --rm \
    --net=host \
    -v "${HOME}/.kube/config:/root/.kube/config:ro" \
    -p "${PORT}:8080" \
    komodorio/helm-dashboard:latest \
    --port="${PORT}" \
    --bind=0.0.0.0
elif helm plugin list | grep -q dashboard; then
  helm dashboard --port="${PORT}" --bind=0.0.0.0
else
  echo "Installing Helm dashboard plugin..."
  helm plugin install https://github.com/komodorio/helm-dashboard.git || true
  helm dashboard --port="${PORT}" --bind=0.0.0.0
fi
