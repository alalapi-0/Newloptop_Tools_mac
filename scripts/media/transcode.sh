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
OUTPUT=""
OUT_DIR="${ROOT_DIR}/out"
PRESET="medium"
CRF=18
AUDIO_BITRATE="192k"

print_help() {
  cat <<'HELP'
Usage:
  ./bin/media transcode --in <file> [--preset fast|medium|slow] [--crf 18] [--audio-bitrate 192k] [--out <file>] [--out-dir <dir>] [--dry-run]

Examples:
  ./bin/media transcode --in demo.mov
  ./bin/media transcode --in demo.mov --preset fast --crf 20
  ./bin/media transcode --in demo.mov --out out/demo_h264.mp4
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
    --out)
      OUTPUT="$2"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    --preset)
      PRESET="$2"
      shift 2
      ;;
    --crf)
      CRF="$2"
      shift 2
      ;;
    --audio-bitrate)
      AUDIO_BITRATE="$2"
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

case "${PRESET}" in
  fast|medium|slow)
    ;;
  *)
    log_err "Invalid --preset: ${PRESET} (use fast|medium|slow)"
    exit 1
    ;;
 esac

ensure_dir "${OUT_DIR}"
require_ffmpeg

if [[ -z "${OUTPUT}" ]]; then
  base="$(basename "${INPUT}")"
  base="${base%.*}"
  OUTPUT="${OUT_DIR}/${base}_h264.mp4"
fi
OUTPUT="$(unique_path "${OUTPUT}")"

CMD=(ffmpeg -hide_banner -i "${INPUT}" -c:v libx264 -preset "${PRESET}" -crf "${CRF}" -c:a aac -b:a "${AUDIO_BITRATE}" "${OUTPUT}")

log_info "Output: ${OUTPUT}"
log_info "Command: $(format_cmd "${CMD[@]}")"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] skip execution"
  exit 0
fi

"${CMD[@]}"
