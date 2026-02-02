#!/usr/bin/env bash
set -euo pipefail

require_tool() {
  local tool="$1"
  if ! command -v "${tool}" >/dev/null 2>&1; then
    log_err "缺少依赖: ${tool}"
    log_err "请先执行 ./bin/setup --only packages_media"
    log_err "或参考 docs/SETUP_MAC.md 的手动安装段"
    return 1
  fi
}

require_ffmpeg() {
  require_tool "ffmpeg"
}

require_ffprobe() {
  require_tool "ffprobe"
}

require_mediainfo() {
  require_tool "mediainfo"
}
