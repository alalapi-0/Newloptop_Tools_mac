#!/usr/bin/env bash
set -euo pipefail

declare -a SETUP_SKIP_STEPS=()
SETUP_DRY_RUN=0
SETUP_YES=0
SETUP_ONLY=""
SETUP_LOG_DIR=""
SETUP_PROFILE="default"

print_help() {
  local steps
  steps="$(step_print_list)"
  cat <<HELP
Newloptop_Tools_mac setup helper (macOS only)

Usage:
  ./bin/setup [options]

Examples:
  ./bin/setup --help
  ./bin/setup --dry-run
  ./bin/setup --only homebrew
  ./bin/setup --skip apps_cask
  ./bin/setup --yes

Steps (in order):
${steps}

Options:
  --help            Show this help message
  --dry-run         Print what would be executed without making changes
  --yes             Allow steps to perform auto-confirm actions (future)
  --only <step>     Run only the specified step
  --skip <step>     Skip the specified step (repeatable or comma-separated)
  --log-dir <path>  Directory to write logs (default: logs/)
  --profile <name>  Execution profile (reserved for R3)
HELP
}

add_skip_steps() {
  local value="$1"
  local IFS=','
  read -r -a parts <<< "${value}"
  local part
  for part in "${parts[@]}"; do
    if [[ -n "${part}" ]]; then
      SETUP_SKIP_STEPS+=("${part}")
    fi
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help)
        print_help
        exit 0
        ;;
      --dry-run)
        SETUP_DRY_RUN=1
        shift
        ;;
      --yes)
        SETUP_YES=1
        shift
        ;;
      --only)
        if [[ -z "${2:-}" ]]; then
          log_err "--only requires a step name"
          exit 1
        fi
        SETUP_ONLY="$2"
        shift 2
        ;;
      --skip)
        if [[ -z "${2:-}" ]]; then
          log_err "--skip requires a step name"
          exit 1
        fi
        add_skip_steps "$2"
        shift 2
        ;;
      --log-dir)
        if [[ -z "${2:-}" ]]; then
          log_err "--log-dir requires a path"
          exit 1
        fi
        SETUP_LOG_DIR="$2"
        shift 2
        ;;
      --profile)
        if [[ -z "${2:-}" ]]; then
          log_err "--profile requires a name"
          exit 1
        fi
        SETUP_PROFILE="$2"
        shift 2
        ;;
      *)
        log_err "Unknown option: $1"
        exit 1
        ;;
    esac
  done
}
