#!/usr/bin/env bash
# =========================================================================
# Launch Komodor Helm Dashboard (Port 8085)
# =========================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

"${ROOT_DIR}/helm-dashboard/run-dashboard.sh" "$@"
