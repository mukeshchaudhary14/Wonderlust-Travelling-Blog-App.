#!/usr/bin/env bash
# =========================================================================
# Build Docker Images for Wonderlust Application
# =========================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

DOCKER_USER="mukeshchaudhary14"
TAG="${1:-latest}"

echo "=========================================================="
echo "🐳 Building Wonderlust Docker Images (Tag: ${TAG})"
echo "=========================================================="

echo "📦 [1/2] Building Backend Image..."
docker build \
  -t "${DOCKER_USER}/wonderlust-backend:${TAG}" \
  -f "${ROOT_DIR}/backend/Dockerfile" \
  "${ROOT_DIR}/backend"

echo "📦 [2/2] Building Frontend Image..."
docker build \
  -t "${DOCKER_USER}/wonderlust-frontend:${TAG}" \
  -f "${ROOT_DIR}/frontend/Dockerfile" \
  "${ROOT_DIR}/frontend"

echo ""
echo "✅ Both images built successfully:"
echo "   - ${DOCKER_USER}/wonderlust-backend:${TAG}"
echo "   - ${DOCKER_USER}/wonderlust-frontend:${TAG}"
