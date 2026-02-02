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
FORMAT="m4a"
OUTPUT=""
OUT_DIR="${ROOT_DIR}/out"

print_help() {
  cat <<'HELP'
Usage:
  ./bin/media extract-audio --in <file> [--format m4a|wav|mp3] [--out <file>] [--out-dir <dir>] [--dry-run]

Examples:
  ./bin/media extract-audio --in demo.mp4
  ./bin/media extract-audio --in demo.mp4 --format wav
  ./bin/media extract-audio --in demo.mp4 --format mp3 --out out/demo.mp3
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
  m4a|wav|mp3)
    ;;
  *)
    log_err "Invalid --format: ${FORMAT} (use m4a|wav|mp3)"
    exit 1
    ;;
 esac

ensure_dir "${OUT_DIR}"
require_ffmpeg

if [[ -z "${OUTPUT}" ]]; then
  base="$(basename "${INPUT}")"
  base="${base%.*}"
  OUTPUT="${OUT_DIR}/${base}_audio.${FORMAT}"
fi
OUTPUT="$(unique_path "${OUTPUT}")"

case "${FORMAT}" in
  m4a)
    CMD=(ffmpeg -hide_banner -i "${INPUT}" -vn -c:a copy "${OUTPUT}")
    ;;
  wav)
    CMD=(ffmpeg -hide_banner -i "${INPUT}" -vn -c:a pcm_s16le "${OUTPUT}")
    ;;
  mp3)
    CMD=(ffmpeg -hide_banner -i "${INPUT}" -vn -c:a libmp3lame -b:a 192k "${OUTPUT}")
    ;;
 esac

log_info "Output: ${OUTPUT}"
log_info "Command: $(format_cmd "${CMD[@]}")"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] skip execution"
  exit 0
fi

"${CMD[@]}"
