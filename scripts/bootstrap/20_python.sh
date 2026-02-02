#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="python"

log_info "==> Step: ${STEP_NAME}"

config_file="${SETUP_REPO_ROOT}/config/packages/python.env"

if [[ -f "${config_file}" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "${config_file}"
  set +a
fi

python_version="${PYTHON_VERSION:-3.12.8}"

pyenv_snippet=$(cat <<'PYENV'
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
PYENV
)

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    log_err "Homebrew not found. Run ./bin/setup --only homebrew first."
  fi
  log_info "[dry-run] Would install pyenv via Homebrew."
  if [[ "${SETUP_YES}" -eq 1 ]]; then
    log_info "[dry-run] Would append pyenv init block to ~/.zshrc."
  else
    log_info "[dry-run] Would prompt to add the following to ~/.zshrc:"
    log_info "${pyenv_snippet}"
  fi
  log_info "[dry-run] Would install Python ${python_version} with pyenv."
  log_info "[dry-run] Would set pyenv global ${python_version}."
  log_info "[dry-run] Would run: python -m pip install --upgrade pip"
  log_info "[dry-run] Would verify: pyenv --version; python --version; which python; pip --version"
  log_info "Step ${STEP_NAME} completed."
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  log_err "Homebrew not found. Run ./bin/setup --only homebrew first."
  log_info "Next: ./bin/setup --only homebrew"
  exit 1
fi

if ! command -v pyenv >/dev/null 2>&1; then
  log_info "pyenv not found. Installing via Homebrew..."
  brew install pyenv
else
  log_info "pyenv already installed: $(command -v pyenv)"
fi

pyenv_block_start="# >>> pyenv initialize >>>"
pyenv_block_end="# <<< pyenv initialize <<<"
pyenv_block=$(cat <<'PYENV'
# >>> pyenv initialize >>>
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# <<< pyenv initialize <<<
PYENV
)

zshrc_path="${HOME}/.zshrc"

if [[ "${SETUP_YES}" -eq 1 ]]; then
  if [[ ! -f "${zshrc_path}" ]]; then
    touch "${zshrc_path}"
  fi
  if grep -Fq "${pyenv_block_start}" "${zshrc_path}"; then
    log_info "pyenv init block already present in ${zshrc_path}."
  else
    log_info "Appending pyenv init block to ${zshrc_path}."
    printf '\n%s\n' "${pyenv_block}" >> "${zshrc_path}"
  fi
else
  log_warn "SETUP_YES not set. Add the following to ${zshrc_path}:"
  log_info "${pyenv_snippet}"
  log_info "Then run: source ${zshrc_path}"
fi

export PYENV_ROOT="${HOME}/.pyenv"
command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:${PATH}"
if command -v pyenv >/dev/null 2>&1; then
  # shellcheck disable=SC1090
  eval "$(pyenv init -)"
fi

if pyenv install --help 2>&1 | grep -q '\-s'; then
  log_info "Installing Python ${python_version} via pyenv (idempotent)."
  pyenv install -s "${python_version}"
else
  if pyenv versions --bare | grep -qx "${python_version}"; then
    log_info "Python ${python_version} already installed in pyenv."
  else
    log_info "Installing Python ${python_version} via pyenv."
    pyenv install "${python_version}"
  fi
fi

log_info "Setting pyenv global to ${python_version}."
pyenv global "${python_version}"

log_info "Upgrading pip."
python -m pip install --upgrade pip

log_info "pyenv --version: $(pyenv --version)"
log_info "python --version: $(python --version 2>&1)"
log_info "which python: $(command -v python)"
log_info "pip --version: $(pip --version)"

log_info "Step ${STEP_NAME} completed."
