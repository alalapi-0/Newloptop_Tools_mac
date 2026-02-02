#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="xcode_clt"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Would run: xcode-select --install"
  log_info "[dry-run] Would verify: xcode-select -p; clang --version"
else
  log_info "Guided placeholder (no changes made)."
  log_info "Run manually: xcode-select --install"
  log_info "Verify: xcode-select -p; clang --version"
fi

log_info "Step ${STEP_NAME} completed."
