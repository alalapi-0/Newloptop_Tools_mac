#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck source=../utils/log.sh
source "${ROOT_DIR}/scripts/utils/log.sh"
# shellcheck source=../utils/fs.sh
source "${ROOT_DIR}/scripts/utils/fs.sh"
# shellcheck source=../utils/media_deps.sh
source "${ROOT_DIR}/scripts/utils/media_deps.sh"

DRY_RUN=0
LIST_FILE=""
OUTPUT=""
OUT_DIR="${ROOT_DIR}/out"

print_help() {
  cat <<'HELP'
Usage:
  ./bin/media concat --list <list.txt> [--out <file>] [--out-dir <dir>] [--dry-run]

Examples:
  ./bin/media concat --list list.txt
  ./bin/media concat --list list.txt --out out/merged.mp4
  ./bin/media concat --list list.txt --dry-run
HELP
}

format_cmd() {
  printf '%q ' "$@"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      print_help
      exit 0
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --list)
      LIST_FILE="$2"
      shift 2
      ;;
    --out)
      OUTPUT="$2"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    *)
      log_err "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
 done

if [[ -z "${LIST_FILE}" ]]; then
  log_err "--list is required"
  print_help
  exit 1
fi

if [[ ! -f "${LIST_FILE}" ]]; then
  log_err "List file not found: ${LIST_FILE}"
  exit 1
fi

ensure_dir "${OUT_DIR}"
require_ffmpeg

if [[ -z "${OUTPUT}" ]]; then
  OUTPUT="${OUT_DIR}/concat.mp4"
fi
OUTPUT="$(unique_path "${OUTPUT}")"

TIMESTAMP="$(date "+%Y%m%d_%H%M%S")"
TEMP_LIST="${OUT_DIR}/concat_${TIMESTAMP}.txt"

line_count=0
> "${TEMP_LIST}"
while IFS= read -r raw_line || [[ -n "${raw_line}" ]]; do
  line="$(trim "${raw_line}")"
  if [[ -z "${line}" || "${line}" == \#* ]]; then
    continue
  fi
  if [[ ! -f "${line}" ]]; then
    log_warn "[SKIP] input not found: ${line}"
    continue
  fi
  printf "file '%s'\n" "${line}" >> "${TEMP_LIST}"
  line_count=$((line_count + 1))
  log_info "[ADD] ${line}"
 done < "${LIST_FILE}"

if [[ "${line_count}" -eq 0 ]]; then
  log_err "No valid input files in list"
  rm -f "${TEMP_LIST}"
  exit 1
fi

CMD=(ffmpeg -hide_banner -f concat -safe 0 -i "${TEMP_LIST}" -c copy "${OUTPUT}")

log_info "Output: ${OUTPUT}"
log_info "Concat list: ${TEMP_LIST}"
log_info "Command: $(format_cmd "${CMD[@]}")"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] skip execution"
  rm -f "${TEMP_LIST}"
  exit 0
fi

"${CMD[@]}"
rm -f "${TEMP_LIST}"
