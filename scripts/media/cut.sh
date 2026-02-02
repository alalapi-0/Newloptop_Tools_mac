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
START_TS=""
END_TS=""
OUTPUT=""
TASKS_FILE=""
OUT_DIR="${ROOT_DIR}/out"
REENCODE=0
CRF=20
PRESET="medium"

print_help() {
  cat <<'HELP'
Usage:
  ./bin/media cut --in <file> --start <ts> --end <ts> [--out <file>] [--reencode 0|1] [--out-dir <dir>] [--dry-run]
  ./bin/media cut --tasks <tasks.txt> [--out-dir <dir>] [--reencode 0|1] [--dry-run]

Timestamp format:
  HH:MM:SS
  HH:MM:SS.mmm
  MM:SS (treated as 00:MM:SS)

Examples:
  ./bin/media cut --in demo.mp4 --start 00:01:10 --end 00:02:00
  ./bin/media cut --in demo.mp4 --start 01:10 --end 02:00 --reencode 1
  ./bin/media cut --tasks tasks.txt
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

sanitize_ts() {
  local value="$1"
  value="${value//:/-}"
  value="${value//./-}"
  printf '%s' "${value}"
}

build_cmd() {
  local input="$1"
  local start="$2"
  local end="$3"
  local output="$4"

  if [[ "${REENCODE}" -eq 1 ]]; then
    printf '%s\n' "ffmpeg -hide_banner -ss ${start} -to ${end} -i ${input} -c:v libx264 -preset ${PRESET} -crf ${CRF} -c:a aac -b:a 192k ${output}"
  else
    printf '%s\n' "ffmpeg -hide_banner -ss ${start} -to ${end} -i ${input} -c copy ${output}"
  fi
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
    --start)
      START_TS="$2"
      shift 2
      ;;
    --end)
      END_TS="$2"
      shift 2
      ;;
    --out)
      OUTPUT="$2"
      shift 2
      ;;
    --tasks)
      TASKS_FILE="$2"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    --reencode)
      REENCODE="$2"
      shift 2
      ;;
    --crf)
      CRF="$2"
      shift 2
      ;;
    --preset)
      PRESET="$2"
      shift 2
      ;;
    *)
      log_err "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
 done

if [[ -n "${TASKS_FILE}" && -n "${INPUT}" ]]; then
  log_err "Use either --in or --tasks, not both"
  exit 1
fi

if [[ -z "${TASKS_FILE}" && -z "${INPUT}" ]]; then
  log_err "--in or --tasks is required"
  print_help
  exit 1
fi

ensure_dir "${OUT_DIR}"
require_ffmpeg

if [[ "${REENCODE}" -eq 0 ]]; then
  log_warn "默认使用 -c copy，可能因关键帧导致起止时间偏移，可用 --reencode 1 提升精度"
fi

if [[ -n "${TASKS_FILE}" ]]; then
  if [[ ! -f "${TASKS_FILE}" ]]; then
    log_err "Tasks file not found: ${TASKS_FILE}"
    exit 1
  fi

  while IFS= read -r raw_line || [[ -n "${raw_line}" ]]; do
    line="$(trim "${raw_line}")"
    if [[ -z "${line}" || "${line}" == \#* ]]; then
      continue
    fi

    if [[ "${line}" == *$'\t'* ]]; then
      IFS=$'\t' read -r task_input task_start task_end task_output <<< "${line}"
    else
      IFS='|' read -r task_input task_start task_end task_output <<< "${line}"
    fi

    task_input="$(trim "${task_input:-}")"
    task_start="$(trim "${task_start:-}")"
    task_end="$(trim "${task_end:-}")"
    task_output="$(trim "${task_output:-}")"

    if [[ -z "${task_input}" || -z "${task_start}" || -z "${task_end}" ]]; then
      log_warn "[SKIP] invalid task line: ${line}"
      continue
    fi

    if [[ ! -f "${task_input}" ]]; then
      log_warn "[SKIP] input not found: ${task_input}"
      continue
    fi

    if [[ -n "${task_output}" ]]; then
      if [[ "${task_output}" != *.* ]]; then
        task_output="${task_output}.mp4"
      fi
      output_path="${OUT_DIR}/${task_output}"
    else
      base="$(basename "${task_input}")"
      base="${base%.*}"
      start_clean="$(sanitize_ts "${task_start}")"
      end_clean="$(sanitize_ts "${task_end}")"
      output_path="${OUT_DIR}/${base}_cut_${start_clean}-${end_clean}.mp4"
    fi

    output_path="$(unique_path "${output_path}")"

    if [[ "${REENCODE}" -eq 1 ]]; then
      cmd=(ffmpeg -hide_banner -ss "${task_start}" -to "${task_end}" -i "${task_input}" -c:v libx264 -preset "${PRESET}" -crf "${CRF}" -c:a aac -b:a 192k "${output_path}")
    else
      cmd=(ffmpeg -hide_banner -ss "${task_start}" -to "${task_end}" -i "${task_input}" -c copy "${output_path}")
    fi

    log_info "Task output: ${output_path}"
    log_info "Command: $(format_cmd "${cmd[@]}")"

    if [[ "${DRY_RUN}" -eq 1 ]]; then
      log_info "[dry-run] [OK] ${task_input}"
      continue
    fi

    if "${cmd[@]}"; then
      log_info "[OK] ${task_input}"
    else
      log_err "[FAIL] ${task_input}"
    fi
  done < "${TASKS_FILE}"
  exit 0
fi

if [[ -z "${START_TS}" || -z "${END_TS}" ]]; then
  log_err "--start and --end are required"
  print_help
  exit 1
fi

if [[ ! -f "${INPUT}" ]]; then
  log_err "Input not found: ${INPUT}"
  exit 1
fi

if [[ -z "${OUTPUT}" ]]; then
  base="$(basename "${INPUT}")"
  base="${base%.*}"
  start_clean="$(sanitize_ts "${START_TS}")"
  end_clean="$(sanitize_ts "${END_TS}")"
  OUTPUT="${OUT_DIR}/${base}_cut_${start_clean}-${end_clean}.mp4"
fi
OUTPUT="$(unique_path "${OUTPUT}")"

if [[ "${REENCODE}" -eq 1 ]]; then
  CMD=(ffmpeg -hide_banner -ss "${START_TS}" -to "${END_TS}" -i "${INPUT}" -c:v libx264 -preset "${PRESET}" -crf "${CRF}" -c:a aac -b:a 192k "${OUTPUT}")
else
  CMD=(ffmpeg -hide_banner -ss "${START_TS}" -to "${END_TS}" -i "${INPUT}" -c copy "${OUTPUT}")
fi

log_info "Output: ${OUTPUT}"
log_info "Command: $(format_cmd "${CMD[@]}")"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  log_info "[dry-run] skip execution"
  exit 0
fi

"${CMD[@]}"
