#!/usr/bin/env bash

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() {
  printf '%b[INFO]%b %s\n' "$GREEN" "$NC" "$1"
}

log_warn() {
  printf '%b[WARN]%b %s\n' "$YELLOW" "$NC" "$1"
}

log_error() {
  printf '%b[ERROR]%b %s\n' "$RED" "$NC" "$1" >&2
}

require_commands() {
  local command_name
  for command_name in "$@"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      log_error "Required command not found: ${command_name}"
      exit 2
    fi
  done
}

read_nix_version() {
  local source_file="$1"
  sed -n 's/^[[:space:]]*version = "\([^"]*\)";/\1/p' "$source_file" | head -n1
}

replace_nix_version() {
  local source_file="$1"
  local new_version="$2"
  sed -i -E "s/^([[:space:]]*version = \")[^\"]*(\";)/\\1${new_version}\\2/" "$source_file"
}

prefetch_sri() {
  nix store prefetch-file --json --hash-type sha256 "$1" | jq -r '.hash'
}

verify_package_build() {
  local build_dir="$1"
  local package_attr="$2"
  log_info "Building path:${build_dir}#${package_attr}"
  nix build "path:${build_dir}#${package_attr}" --no-link
}
