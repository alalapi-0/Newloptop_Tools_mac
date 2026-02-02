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
INPUT=""
FORMAT="txt"
OUTPUT=""
OUT_DIR="${ROOT_DIR}/out"

print_help() {
  cat <<'HELP'
Usage:
  ./bin/media probe --in <file> [--format json|txt] [--out <file>] [--out-dir <dir>] [--dry-run]

Examples:
  ./bin/media probe --in demo.mp4
  ./bin/media probe --in demo.mp4 --format json
  ./bin/media probe --in demo.mp4 --out out/info.txt
HELP
}

format_cmd() {
  printf '%q ' "$@"
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
    --in)
      INPUT="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
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

if [[ -z "${INPUT}" ]]; then
  log_err "--in is required"
  print_help
  exit 1
fi

if [[ ! -f "${INPUT}" ]]; then
  log_err "Input not found: ${INPUT}"
  exit 1
fi

case "${FORMAT}" in
  json|txt)
    ;;
  *)
    log_err "Invalid --format: ${FORMAT} (use json|txt)"
    exit 1
    ;;
 esac

ensure_dir "${OUT_DIR}"

if [[ -z "${OUTPUT}" ]]; then
  base="$(basename "${INPUT}")"
  base="${base%.*}"
  OUTPUT="${OUT_DIR}/${base}_probe.${FORMAT}"
fi
OUTPUT="$(unique_path "${OUTPUT}")"

if [[ "${FORMAT}" == "json" ]]; then
  require_ffprobe
  CMD=(ffprobe -v quiet -print_format json -show_format -show_streams "${INPUT}")
else
  require_mediainfo
  CMD=(mediainfo "${INPUT}")
fi

log_info "Output: ${OUTPUT}"
log_info "Command: $(format_cmd "${CMD[@]}")"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] skip execution"
  exit 0
fi

"${CMD[@]}" | tee "${OUTPUT}"
