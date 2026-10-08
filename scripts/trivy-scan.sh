#!/usr/bin/env bash
# =========================================================================
# Trivy Security Scanner Automation Script for Wonderlust Application
# =========================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPORT_DIR="${ROOT_DIR}/trivy-reports"

BACKEND_IMAGE="mukeshchaudhary14/wonderlust-backend:latest"
FRONTEND_IMAGE="mukeshchaudhary14/wonderlust-frontend:latest"

mkdir -p "${REPORT_DIR}"
mkdir -p "${HOME}/.cache/trivy"

echo "=========================================================="
echo "🛡️  Starting Trivy Security & Vulnerability Scan"
echo "📂 Project Directory: ${ROOT_DIR}"
echo "📊 Output Reports:    ${REPORT_DIR}"
echo "=========================================================="

run_trivy() {
  if command -v trivy >/dev/null 2>&1; then
    trivy "$@"
  else
    docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "${ROOT_DIR}:/workspace" \
      -v "${HOME}/.cache/trivy:/root/.cache/trivy" \
      aquasec/trivy:latest "$@"
  fi
}

# 1. File System / Repository Scan
echo ""
echo "🔍 [1/4] Scanning Source Code & Dependencies (Filesystem Scan)..."
run_trivy fs \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --scanners vuln,secret,config \
  --format table \
  /workspace > "${REPORT_DIR}/trivy-fs-report.txt" || true

run_trivy fs \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --scanners vuln,secret,config \
  --format json \
  --output "/workspace/trivy-reports/trivy-fs-report.json" \
  /workspace || true
echo "✅ Filesystem scan completed. Saved to ${REPORT_DIR}/trivy-fs-report.txt"

# 2. Backend Container Image Scan
echo ""
echo "🐳 [2/4] Scanning Backend Container Image: ${BACKEND_IMAGE}..."
if docker image inspect "${BACKEND_IMAGE}" >/dev/null 2>&1; then
  run_trivy image \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --format table \
    "${BACKEND_IMAGE}" > "${REPORT_DIR}/trivy-backend-image-report.txt" || true

  run_trivy image \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --format json \
    --output "/workspace/trivy-reports/trivy-backend-image-report.json" \
    "${BACKEND_IMAGE}" || true
  echo "✅ Backend image scan completed. Saved to ${REPORT_DIR}/trivy-backend-image-report.txt"
else
  echo "⚠️ Backend image '${BACKEND_IMAGE}' not found locally. Skipping image scan."
fi

# 3. Frontend Container Image Scan
echo ""
echo "🐳 [3/4] Scanning Frontend Container Image: ${FRONTEND_IMAGE}..."
if docker image inspect "${FRONTEND_IMAGE}" >/dev/null 2>&1; then
  run_trivy image \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --format table \
    "${FRONTEND_IMAGE}" > "${REPORT_DIR}/trivy-frontend-image-report.txt" || true

  run_trivy image \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --format json \
    --output "/workspace/trivy-reports/trivy-frontend-image-report.json" \
    "${FRONTEND_IMAGE}" || true
  echo "✅ Frontend image scan completed. Saved to ${REPORT_DIR}/trivy-frontend-image-report.txt"
else
  echo "⚠️ Frontend image '${FRONTEND_IMAGE}' not found locally. Skipping image scan."
fi

# 4. Kubernetes & Helm IaC Misconfiguration Scan
echo ""
echo "☸️ [4/4] Scanning Kubernetes & Helm IaC Configurations..."
run_trivy config \
  --severity HIGH,CRITICAL \
  --format table \
  /workspace/k8s > "${REPORT_DIR}/trivy-iac-report.txt" || true

echo "✅ IaC configuration scan completed. Saved to ${REPORT_DIR}/trivy-iac-report.txt"

echo ""
echo "=========================================================="
echo "🎉 All Trivy Scans Completed Successfully!"
echo "📁 Reports available in: ${REPORT_DIR}"
echo "=========================================================="
