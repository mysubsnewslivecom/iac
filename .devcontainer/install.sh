#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.0"
DEFAULT_BIN_DIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"
export PATH="$PATH:${DEFAULT_BIN_DIR}"

# Color codes
GREEN="\e[0;92m"
RED="\e[0;91m"
YELLOW_BOLD="\e[1;33m"
GREEN_BOLD="\e[1;32m"
RESET="\e[0m"

log() {
  local msg="$1"
  printf "❯ ${GREEN_BOLD}%s${RESET}\n" "$msg"
}

log_h() {
  local msg="$1"
  printf "❯ ${YELLOW_BOLD}%s${RESET}\n" "$msg"
}

if [ ! -d "$DEFAULT_BIN_DIR" ]; then
  mkdir -p "$DEFAULT_BIN_DIR"
fi

declare -A VERSIONS=(
  [helm]="v3.16.4"
  [terraform]="1.11.3"
  [k9s]="v0.50.2"
  [kubectl]="v1.32.0"
  [vault]="1.18.1"
)

# Download URLs for tools
declare -A DOWNLOAD_URLS=(
  [helm]="https://get.helm.sh/helm-${VERSIONS[helm]}-linux-amd64.tar.gz"
  [yq]="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
  [kubectl]="https://dl.k8s.io/${VERSIONS[kubectl]}/bin/linux/amd64/kubectl"
  [terraform]="https://releases.hashicorp.com/terraform/${VERSIONS[terraform]}/terraform_${VERSIONS[terraform]}_linux_amd64.zip"
  [k9s]="https://github.com/derailed/k9s/releases/download/${VERSIONS[k9s]}/k9s_Linux_amd64.tar.gz"
  [task]="https://taskfile.dev/install.sh"
  [flux]="https://fluxcd.io/install.sh"
  [vault]="https://releases.hashicorp.com/vault/${VERSIONS[vault]}/vault_${VERSIONS[vault]}_linux_amd64.zip"
)

# Shell completion commands
declare -A COMPLETIONS=(
  [starship]='eval "$(starship init bash)"'
  [task]='eval "$(task --completion bash)"'
  [flux]='eval "$(flux completion bash)"'
  [kubectl]='eval "$(kubectl completion bash)"'
  [helm]='eval "$(helm completion bash)"'
  [k9s]='eval "$(k9s completion bash)"'
  [docker]='eval "$(docker completion bash)"'
)

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [tool ...]

Commands:
  install [tool ...]  Install specified tool(s). If no tool specified, install all.

Available tools:
  ${!DOWNLOAD_URLS[@]}
EOF
exit 1
}

command_exists() {
  command -v "$1" &>/dev/null
}

install_tool() {
  local tool_name="$1"
  local download_url="${DOWNLOAD_URLS[$tool_name]}"

  if command_exists "$tool_name"; then
    log "$tool_name is already installed."
    return
  fi

  log_h "Installing $tool_name..."

  case "$tool_name" in
    helm)
      curl -fsSL --url "$download_url" | tar xz -C "$DEFAULT_BIN_DIR" --strip-components=1 linux-amd64/helm
      ;;
    yq)
      curl -fsSL --url "$download_url" -o "$DEFAULT_BIN_DIR/yq"
      ;;
    kubectl)
      curl -fsSL --url "$download_url" -o "$DEFAULT_BIN_DIR/kubectl"
      ;;
    terraform)
      curl -fsSL --url "$download_url" -o terraform.zip && unzip terraform.zip && mv terraform "$DEFAULT_BIN_DIR/" && rm terraform.zip
      ;;
    k9s)
      curl -fsSL --url "$download_url" | tar xvz -C "$DEFAULT_BIN_DIR" k9s
      ;;
    task)
      bash -c "$(curl -fsSL --location "$download_url")" -- -d -b "$DEFAULT_BIN_DIR"
      ;;
    flux)
      bash -c "$(curl -fsSL --url "$download_url")" -- "$DEFAULT_BIN_DIR"
      ;;
    vault)
      curl -fsSL --url "$download_url" -o vault.zip && unzip -o vault.zip vault -d "$DEFAULT_BIN_DIR/" && rm vault.zip
      ;;
    *)
      log "Error: Unknown tool: $tool_name"
      return 1
      ;;
  esac

  log "$tool_name installed successfully."
}

add_aliases() {
  local aliases='
alias k=kubectl
complete -o default -F __start_kubectl k
alias kg="kubectl get"
alias kgp="kubectl get po"
alias kdp="kubectl describe pod"
'

  local bashrc="$HOME/.bashrc"
  local all_present=1

  # Read aliases line by line, ignore empty lines
  while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    if ! grep -Fxq "$line" "$bashrc"; then
      echo $line >> "$bashrc"
    fi
  done <<< "$aliases"
}

setup_completions() {
  local BASHRC="$HOME/.bashrc"

  for tool_name in "${!COMPLETIONS[@]}"; do
    local line="${COMPLETIONS[$tool_name]}"

    # Append the line only if it doesn't already exist
    if ! grep -Fxq "$line" "$BASHRC"; then
      echo "$line" >> "$BASHRC"
      log "Added completion for $tool_name to ~/.bashrc"
    else
      log "Completion for $tool_name already exists in ~/.bashrc"
    fi
  done

  # Install Terraform autocomplete if not already installed
  if ! grep -q 'terraform terraform' "$BASHRC"; then
    terraform -install-autocomplete
    log "Installed Terraform autocomplete"
  else
    log "Completion for terraform autocomplete already exists in ~/.bashrc"
  fi

  # Install vault autocomplete if not already installed
  if ! grep -q 'vault vault' "$BASHRC"; then
    vault -autocomplete-install
    log "Installed vault autocomplete"
  else
    log "Completion for vault autocomplete already exists in ~/.bashrc"
  fi
}

setup(){
  log_h "Installing tools..."
  for tool_name in "${!DOWNLOAD_URLS[@]}"; do
    install_tool "${tool_name}"
  done

  log_h "Setting execute permissions..."
  find "$DEFAULT_BIN_DIR" -type f -exec chmod +x {} \;

  log_h "Adding aliases..."
  add_aliases

  log_h "Setting up completions..."
  setup_completions

  log_h "All setup tasks completed."
}

install(){
  local tool_names=("$@")
  for tool_name in ${tool_names[@]}
  do
  if [[ -v DOWNLOAD_URLS[$tool_name] ]]; then
    install_tool "${tool_name}"
  fi
  done
}

main() {
  local cmd
  [[ $# -eq 0 ]] && cmd="setup" || cmd="$1"
  case $cmd in
    setup) setup ;;
    install) install ${@:2} ;;
    *) usage ;;
  esac
}

main "$@"
