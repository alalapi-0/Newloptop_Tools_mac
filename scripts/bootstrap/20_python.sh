#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="python"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Would run: brew install pyenv"
  log_info "[dry-run] Would append pyenv init to shell rc"
  log_info "[dry-run] Would verify: pyenv --version; python --version"
else
  log_info "Guided placeholder (no changes made)."
  log_info "Run manually: brew install pyenv"
  log_info "Add pyenv init block to ~/.zshrc and reload shell."
  if [[ "${SETUP_YES}" -eq 1 ]]; then
    log_info "With --yes, this step would append pyenv init snippets in a future release."
  fi
  log_info "Verify: pyenv --version; python --version"
fi

log_info "Step ${STEP_NAME} completed."
