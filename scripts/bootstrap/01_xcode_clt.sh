#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="xcode_clt"

log_info "==> Step: ${STEP_NAME}"

if xcode-select -p >/dev/null 2>&1; then
  local_path="$(xcode-select -p)"
  log_info "Xcode Command Line Tools already installed at: ${local_path}"
  if ! clang --version >/dev/null 2>&1; then
    log_err "clang verification failed. Please reinstall Xcode Command Line Tools."
    exit 1
  fi
  clang_version="$(clang --version | head -n 1)"
  log_info "clang verified: ${clang_version}"
  log_info "Step ${STEP_NAME} completed."
  exit 0
fi

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] Xcode Command Line Tools not found."
  log_info "[dry-run] Would run: xcode-select --install"
  log_info "[dry-run] Would verify: xcode-select -p; clang --version"
  log_info "Step ${STEP_NAME} completed."
  exit 0
fi

log_info "Xcode Command Line Tools not found. Starting installer..."
if ! xcode-select --install; then
  log_err "Failed to start Xcode Command Line Tools installer."
  exit 1
fi
log_warn "Installer launched. Complete the prompt, then re-run this step to verify."
log_info "Step ${STEP_NAME} completed."
