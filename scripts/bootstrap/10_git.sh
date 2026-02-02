#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="git"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Would run: brew install git"
  log_info "[dry-run] Would configure: git config --global user.name/user.email"
  log_info "[dry-run] Would verify: git --version; git config --global -l"
else
  log_info "Guided placeholder (no changes made)."
  log_info "Run manually: brew install git"
  log_info "Configure: git config --global user.name \"Your Name\""
  log_info "Configure: git config --global user.email \"you@example.com\""
  if [[ "${SETUP_YES}" -eq 1 ]]; then
    log_info "With --yes, this step would apply provided Git config values in a future release."
  fi
  log_info "Verify: git --version; git config --global -l"
fi

log_info "Step ${STEP_NAME} completed."
