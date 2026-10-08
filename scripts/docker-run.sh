#!/usr/bin/env bash
# =========================================================================
# Run Wonderlust Local Stack via Docker Compose
# =========================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo "🚀 Starting Wonderlust Services via Docker Compose"
echo "=========================================================="

cd "${ROOT_DIR}"
docker compose up -d --build

echo ""
echo "=========================================================="
echo "🎉 Services are starting in the background!"
echo "🌐 Frontend Client: http://localhost:3000"
echo "🔌 Backend API:     http://localhost:5000"
echo "🗄️  MongoDB:        localhost:27017"
echo "⚡ Redis Cache:     localhost:6379"
echo "=========================================================="
echo "Check status with: docker compose ps"
echo "View logs with:   docker compose logs -f"
