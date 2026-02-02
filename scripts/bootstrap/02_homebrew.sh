#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="homebrew"

log_info "==> Step: ${STEP_NAME}"

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    echo "/opt/homebrew/bin/brew"
    return 0
  fi

  if [[ -x "/usr/local/bin/brew" ]]; then
    echo "/usr/local/bin/brew"
    return 0
  fi

  return 1
}

brew_bin="$(find_brew || true)"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  if [[ -n "${brew_bin}" ]]; then
    log_info "[dry-run] Homebrew detected at: ${brew_bin}"
  else
    log_info "[dry-run] Homebrew not found. Would run install script."
  fi
  log_info "[dry-run] Would configure shellenv for brew path."
  log_info "[dry-run] Would verify: brew --version; brew doctor; brew update"
  log_info "Step ${STEP_NAME} completed."
  exit 0
fi

if [[ -z "${brew_bin}" ]]; then
  log_info "Homebrew not found. Installing..."
  if ! command -v curl >/dev/null 2>&1; then
    log_err "curl is required to install Homebrew."
    exit 1
  fi
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    log_err "Homebrew install failed. Check your network and try again."
    exit 1
  fi
  brew_bin="$(find_brew || true)"
fi

if [[ -z "${brew_bin}" ]]; then
  log_err "Homebrew installation completed but brew was not found."
  exit 1
fi

log_info "Homebrew available at: ${brew_bin}"

shellenv_line="eval \"\$(${brew_bin} shellenv)\""
zprofile_path="${HOME}/.zprofile"

if [[ "${SETUP_YES}" -eq 1 ]]; then
  if [[ ! -f "${zprofile_path}" ]]; then
    touch "${zprofile_path}"
  fi
  if grep -Fq "${shellenv_line}" "${zprofile_path}"; then
    log_info "shellenv already present in ${zprofile_path}"
  else
    log_info "Appending shellenv to ${zprofile_path}"
    echo "${shellenv_line}" >> "${zprofile_path}"
  fi
  log_info "Applying shellenv for current session."
  # shellcheck disable=SC1090
  eval "$(${brew_bin} shellenv)"
else
  log_warn "SETUP_YES not set. Please run the following commands manually:"
  log_info "echo '${shellenv_line}' >> ${zprofile_path}"
  log_info "${shellenv_line}"
fi

if ! "${brew_bin}" --version; then
  log_err "Failed to run brew --version."
  exit 1
fi

if ! "${brew_bin}" update; then
  log_warn "brew update reported issues. Please review the output."
fi

if ! "${brew_bin}" doctor; then
  log_warn "brew doctor reported issues. Please review the output."
fi

log_info "Step ${STEP_NAME} completed."
