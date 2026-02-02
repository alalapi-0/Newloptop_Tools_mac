#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${SETUP_LOG_FILE:-}"

log_init() {
  LOG_FILE="$1"
}

log_line() {
  local level="$1"
  shift
  local message="$*"
  local timestamp
  timestamp="$(date "+%Y-%m-%d %H:%M:%S")"
  local line="[${timestamp}] [${level}] ${message}"
  echo "${line}"
  if [[ -n "${LOG_FILE}" ]]; then
    echo "${line}" >> "${LOG_FILE}"
  fi
}

log_info() {
  log_line "INFO" "$@"
}

log_warn() {
  log_line "WARN" "$@"
}

log_err() {
  log_line "ERROR" "$@"
}
