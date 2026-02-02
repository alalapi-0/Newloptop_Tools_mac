#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="packages_cli"
PROFILE_DIR="${SETUP_REPO_ROOT}/config/packages/profiles"

log_info "==> Step: ${STEP_NAME}"

list_profiles() {
  local profiles=()
  shopt -s nullglob
  local file
  for file in "${PROFILE_DIR}"/*.env; do
    profiles+=("$(basename "${file}" .env)")
  done
  shopt -u nullglob

  if [[ ${#profiles[@]} -eq 0 ]]; then
    log_info "No profiles found in ${PROFILE_DIR}"
  else
    log_info "Available profiles: ${profiles[*]}"
  fi
}

load_profile() {
  local profile_name="$1"
  local profile_file="${PROFILE_DIR}/${profile_name}.env"

  if [[ ! -f "${profile_file}" ]]; then
    log_err "Profile not found: ${profile_name}"
    list_profiles
    exit 1
  fi

  # shellcheck disable=SC1090
  source "${profile_file}"

  if [[ -z "${CLI_LIST:-}" ]]; then
    log_err "CLI_LIST is not set in profile: ${profile_file}"
    exit 1
  fi
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

if ! command -v brew >/dev/null 2>&1; then
  log_err "Homebrew is required for CLI packages. Run --only homebrew first."
  exit 1
fi

load_profile "${SETUP_PROFILE}"

cli_list_path="${CLI_LIST}"
if [[ "${cli_list_path}" != /* ]]; then
  cli_list_path="${SETUP_REPO_ROOT}/${cli_list_path}"
fi

if [[ ! -f "${cli_list_path}" ]]; then
  log_err "CLI list not found: ${cli_list_path}"
  exit 1
fi

log_info "Using CLI list: ${cli_list_path}"

while IFS= read -r line || [[ -n "${line}" ]]; do
  line="${line%%#*}"
  line="$(trim "${line}")"
  if [[ -z "${line}" ]]; then
    continue
  fi

  if brew list --formula "${line}" >/dev/null 2>&1; then
    log_info "Package already installed: ${line}"
    continue
  fi

  if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
    log_info "[dry-run] Would install: ${line}"
    continue
  fi

  log_info "Installing package: ${line}"
  if ! brew install "${line}"; then
    log_err "Failed to install package: ${line}"
    exit 1
  fi
done < "${cli_list_path}"

log_info "Step ${STEP_NAME} completed."
