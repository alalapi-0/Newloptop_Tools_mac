#!/usr/bin/env bash
set -euo pipefail

ensure_dir() {
  local dir="$1"
  if [[ -z "${dir}" ]]; then
    return 1
  fi
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
}

unique_path() {
  local path="$1"
  if [[ -z "${path}" ]]; then
    return 1
  fi
  if [[ ! -e "${path}" ]]; then
    printf '%s' "${path}"
    return 0
  fi

  local dir
  local filename
  local base
  local ext
  local counter
  local candidate

  dir="$(dirname "${path}")"
  filename="$(basename "${path}")"

  if [[ "${filename}" == *.* ]]; then
    ext=".${filename##*.}"
    base="${filename%.*}"
  else
    ext=""
    base="${filename}"
  fi

  counter=2
  while :; do
    candidate="${dir}/${base}_${counter}${ext}"
    if [[ ! -e "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
    counter=$((counter + 1))
  done
}
