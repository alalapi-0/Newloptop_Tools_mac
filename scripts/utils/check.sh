#!/usr/bin/env bash
set -euo pipefail

check_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_err "This setup is intended for macOS only."
    exit 1
  fi
}

check_bash() {
  if ! command -v bash >/dev/null 2>&1; then
    log_err "bash is required but was not found."
    exit 1
  fi
}

check_log_dir() {
  local dir="$1"
  if ! mkdir -p "${dir}" 2>/dev/null; then
    log_err "Unable to create log directory: ${dir}"
    exit 1
  fi
  local test_file="${dir}/.write_test"
  if ! touch "${test_file}" 2>/dev/null; then
    log_err "Log directory is not writable: ${dir}"
    exit 1
  fi
  rm -f "${test_file}"
}

check_network() {
  if ! command -v ping >/dev/null 2>&1; then
    log_warn "ping command not found; skipping network check."
    return 0
  fi

  if ! ping -c 1 -t 2 8.8.8.8 >/dev/null 2>&1; then
    log_warn "Network check failed; continue if you are offline."
  fi
}

check_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    log_warn "Homebrew not found. Run the homebrew step or follow docs/SETUP_MAC.md."
  fi
}
