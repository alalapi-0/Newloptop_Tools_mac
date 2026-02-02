#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="packages_cli"
PACKAGE_HINT="${SETUP_REPO_ROOT}/config/packages"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Would install CLI packages from ${PACKAGE_HINT}."
  log_info "[dry-run] Would verify key CLI tools (rg, fd, bat, etc.)."
else
  log_info "Guided placeholder (no changes made)."
  log_info "Planned source of package list: ${PACKAGE_HINT}."
  log_info "Verify: rg --version; fd --version; bat --version"
fi

log_info "Step ${STEP_NAME} completed."
