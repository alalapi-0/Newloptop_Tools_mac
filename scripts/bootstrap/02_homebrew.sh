#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="homebrew"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Would run Homebrew install script."
  log_info "[dry-run] Would suggest shellenv setup for your CPU type."
  log_info "[dry-run] Would verify: brew --version; brew doctor; brew update"
else
  log_info "Guided placeholder (no changes made)."
  log_info "Run manually: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  log_info "Then add brew shellenv to ~/.zprofile (Apple Silicon or Intel as appropriate)."
  if [[ "${SETUP_YES}" -eq 1 ]]; then
    log_info "With --yes, this step would append shellenv to ~/.zprofile in a future release."
  fi
  log_info "Verify: brew --version; brew doctor; brew update"
fi

log_info "Step ${STEP_NAME} completed."
