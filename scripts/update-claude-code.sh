#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
# shellcheck source=scripts/lib/update-common.sh
source "${script_dir}/lib/update-common.sh"

readonly package_file="${repo_root}/nix/packages/claude-code.nix"
readonly download_base_url="https://downloads.claude.ai/claude-code-releases"

target_version=""
check_only=false
rehash=false
no_build=false

usage() {
  cat <<'EOF'
Usage: scripts/update-claude-code.sh [OPTIONS]

Options:
  --version VERSION  Update to a specific version instead of latest
  --check            Exit 1 when a newer version is available
  --rehash           Recompute hashes for the current or selected version
  --no-build         Skip package build verification
  --help             Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      [ "$#" -ge 2 ] || {
        log_error "--version requires a value"
        exit 2
      }
      target_version="$2"
      shift 2
      ;;
    --check)
      check_only=true
      shift
      ;;
    --rehash)
      rehash=true
      shift
      ;;
    --no-build)
      no_build=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 2
      ;;
  esac
done

require_commands curl jq nix sed awk

current_version="$(read_nix_version "$package_file")"
[ -n "$current_version" ] || {
  log_error "Could not read the current Claude Code version"
  exit 2
}

latest_version="${target_version:-$(curl -fsSL "${download_base_url}/latest")}"
[ -n "$latest_version" ] || {
  log_error "Could not determine the target Claude Code version"
  exit 2
}

if [ "$check_only" = true ]; then
  if [ "$current_version" = "$latest_version" ]; then
    log_info "Claude Code is current (${current_version})"
    exit 0
  fi
  log_warn "Claude Code update available: ${current_version} -> ${latest_version}"
  exit 1
fi

if [ "$current_version" = "$latest_version" ] && [ "$rehash" = false ]; then
  log_info "Claude Code is already at ${current_version}"
  exit 0
fi

manifest="$(curl -fsSL "${download_base_url}/${latest_version}/manifest.json")"
x86_hex="$(jq -er '.platforms["linux-x64"].checksum' <<<"$manifest")"
arm_hex="$(jq -er '.platforms["linux-arm64"].checksum' <<<"$manifest")"
x86_hash="$(nix hash to-sri --type sha256 "$x86_hex")"
arm_hash="$(nix hash to-sri --type sha256 "$arm_hex")"

backup="$(mktemp)"
cp "$package_file" "$backup"
committed=false
cleanup() {
  if [ "$committed" = false ]; then
    cp "$backup" "$package_file"
  fi
  rm -f "$backup"
}
trap cleanup EXIT

replace_nix_version "$package_file" "$latest_version"
temp_file="$(mktemp)"
awk -v x86="$x86_hash" -v arm="$arm_hash" '
  /^[[:space:]]*binaryHashBySystem = \{/ {
    print
    print "    # scripts/update-claude-code.sh managed hashes."
    print "    x86_64-linux = \"" x86 "\";"
    print "    aarch64-linux = \"" arm "\";"
    in_hashes = 1
    next
  }
  in_hashes && /^[[:space:]]*};/ {
    in_hashes = 0
    print
    next
  }
  !in_hashes { print }
' "$package_file" > "$temp_file"
chmod --reference="$package_file" "$temp_file"
mv "$temp_file" "$package_file"

if [ "$no_build" = false ]; then
  verify_package_build "$repo_root" claude-code
fi

committed=true
log_info "Updated Claude Code: ${current_version} -> ${latest_version}"
