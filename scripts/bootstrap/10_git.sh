#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../utils/log.sh
source "${SETUP_REPO_ROOT}/scripts/utils/log.sh"

STEP_NAME="git"

log_info "==> Step: ${STEP_NAME}"

if [[ "${SETUP_DRY_RUN}" -eq 1 ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    log_err "Homebrew not found. Run ./bin/setup --only homebrew first."
  fi
  log_info "[dry-run] Would ensure Git is installed via Homebrew."
  log_info "[dry-run] Would configure: git config --global user.name/user.email"
  log_info "[dry-run] Would optionally generate an SSH key if requested."
  log_info "[dry-run] Would verify: git --version; git config --global -l"
  log_info "Step ${STEP_NAME} completed."
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  log_err "Homebrew not found. Run ./bin/setup --only homebrew first."
  log_info "Next: ./bin/setup --only homebrew"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  log_info "Git not found. Installing via Homebrew..."
  brew install git
else
  log_info "Git already installed: $(command -v git)"
fi

git_name="${GIT_NAME:-}"
git_email="${GIT_EMAIL:-}"

if [[ -z "${git_name}" && "${SETUP_YES}" -eq 0 ]]; then
  read -r -p "Git user.name: " git_name
fi

if [[ -z "${git_email}" && "${SETUP_YES}" -eq 0 ]]; then
  read -r -p "Git user.email: " git_email
fi

if [[ -z "${git_name}" ]]; then
  log_warn "Git user.name not provided; skipping git config user.name."
else
  git config --global user.name "${git_name}"
fi

if [[ -z "${git_email}" ]]; then
  log_warn "Git user.email not provided; skipping git config user.email."
else
  git config --global user.email "${git_email}"
fi

log_info "Git config user.name: $(git config --global user.name || true)"
log_info "Git config user.email: $(git config --global user.email || true)"

should_generate_ssh_key=0
if [[ "${GENERATE_SSH_KEY:-0}" == "1" ]]; then
  should_generate_ssh_key=1
elif [[ "${SETUP_YES}" -eq 0 ]]; then
  read -r -p "Generate SSH key (ed25519) now? [y/N]: " generate_answer
  case "${generate_answer}" in
    y|Y|yes|YES)
      should_generate_ssh_key=1
      ;;
    *)
      should_generate_ssh_key=0
      ;;
  esac
fi

if [[ "${should_generate_ssh_key}" -eq 1 ]]; then
  ssh_key_path="${HOME}/.ssh/id_ed25519"
  if [[ -f "${ssh_key_path}" || -f "${ssh_key_path}.pub" ]]; then
    log_info "SSH key already exists at ${ssh_key_path}; skipping generation."
  else
    mkdir -p "${HOME}/.ssh"
    log_info "Generating SSH key at ${ssh_key_path}..."
    ssh-keygen -t ed25519 -C "${git_email}" -f "${ssh_key_path}" -N ""

    if command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1; then
      # shellcheck disable=SC1090
      eval "$(ssh-agent -s)" >/dev/null
      if ssh-add --apple-use-keychain "${ssh_key_path}"; then
        log_info "SSH key added to ssh-agent with keychain support."
      else
        log_warn "ssh-add --apple-use-keychain failed; trying without keychain."
        if ! ssh-add "${ssh_key_path}"; then
          log_warn "ssh-add failed; you may need to add the key manually."
        fi
      fi
    else
      log_warn "ssh-agent/ssh-add not available; skipping agent add."
    fi
  fi

  log_info "Copy public key with: pbcopy < ~/.ssh/id_ed25519.pub"
else
  log_info "SSH key generation skipped."
fi

log_info "Git version: $(git --version)"
log_info "Step ${STEP_NAME} completed."
