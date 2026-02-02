#!/usr/bin/env bash
set -euo pipefail

declare -a STEP_NAMES=()
declare -a STEP_SCRIPTS=()
declare -a STEP_DESCRIPTIONS=()

register_step() {
  local name="$1"
  local script="$2"
  local description="$3"
  STEP_NAMES+=("${name}")
  STEP_SCRIPTS+=("${script}")
  STEP_DESCRIPTIONS+=("${description}")
}

step_print_list() {
  local output=()
  local i
  for i in "${!STEP_NAMES[@]}"; do
    output+=("  - ${STEP_NAMES[$i]}: ${STEP_DESCRIPTIONS[$i]}")
  done
  printf '%s\n' "${output[@]}"
}

step_exists() {
  local target="$1"
  local name
  for name in "${STEP_NAMES[@]}"; do
    if [[ "${name}" == "${target}" ]]; then
      return 0
    fi
  done
  return 1
}

step_should_run() {
  local name="$1"

  if [[ -n "${SETUP_ONLY}" ]]; then
    if [[ "${name}" == "${SETUP_ONLY}" ]]; then
      return 0
    fi
    return 1
  fi

  if [[ ${#SETUP_SKIP_STEPS[@]} -gt 0 ]]; then
    local skip
    for skip in "${SETUP_SKIP_STEPS[@]}"; do
      if [[ "${skip}" == "${name}" ]]; then
        return 1
      fi
    done
  fi

  return 0
}

step_run_all() {
  local i
  for i in "${!STEP_NAMES[@]}"; do
    local name="${STEP_NAMES[$i]}"
    local script="${STEP_SCRIPTS[$i]}"

    if ! step_should_run "${name}"; then
      log_warn "Skipping step: ${name}"
      continue
    fi

    if [[ ! -f "${script}" ]]; then
      log_err "Step script not found: ${script}"
      exit 1
    fi

    log_info "Running step: ${name}"
    bash "${script}"
  done
}
