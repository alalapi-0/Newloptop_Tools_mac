#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="apps_cask"
PACKAGE_HINT="${SETUP_REPO_ROOT}/config/packages"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Would install GUI apps (casks) from ${PACKAGE_HINT}."
  log_info "[dry-run] Would verify: brew list --cask"
else
  log_info "Guided placeholder (no changes made)."
  log_info "Planned source of cask list: ${PACKAGE_HINT}."
  log_info "Verify: brew list --cask"
fi

log_info "Step ${STEP_NAME} completed."
