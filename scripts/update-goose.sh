#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
# shellcheck source=scripts/lib/update-common.sh
source "${script_dir}/lib/update-common.sh"

readonly flake_dir="${AGENTBOX_FLAKE_DIR:-${repo_root}/nix}"
readonly package_file="${flake_dir}/packages/goose/default.nix"
readonly releases_api="https://api.github.com/repos/block/goose/releases/latest"

target_version=""
target_tag=""
check_only=false
rehash=false
no_build=false

usage() {
  cat <<'EOF'
Usage: scripts/update-goose.sh [OPTIONS]

Options:
  --version VERSION  Update to a specific version instead of latest
  --tag TAG          Update to a specific GitHub release tag instead of latest
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
    --tag)
      [ "$#" -ge 2 ] || {
        log_error "--tag requires a value"
        exit 2
      }
      target_tag="$2"
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

require_commands curl jq nix sed

current_version="$(read_nix_version "$package_file")"
[ -n "$current_version" ] || {
  log_error "Could not read the current Goose version"
  exit 2
}

if [ -n "$target_tag" ]; then
  latest_tag="$target_tag"
  latest_version="${latest_tag#v}"
elif [ -n "$target_version" ]; then
  latest_version="$target_version"
  latest_tag="v${latest_version}"
else
  latest_tag="$(curl -fsSL "$releases_api" | jq -er '.tag_name')"
  latest_version="${latest_tag#v}"
fi

if [ "$check_only" = true ]; then
  if [ "$current_version" = "$latest_version" ]; then
    log_info "Goose is current (${current_version})"
    exit 0
  fi
  log_warn "Goose update available: ${current_version} -> ${latest_version}"
  exit 1
fi

if [ "$current_version" = "$latest_version" ] && [ "$rehash" = false ]; then
  log_info "Goose is already at ${current_version}"
  exit 0
fi

x86_url="https://github.com/block/goose/releases/download/${latest_tag}/goose-x86_64-unknown-linux-gnu.tar.gz"
arm_url="https://github.com/block/goose/releases/download/${latest_tag}/goose-aarch64-unknown-linux-gnu.tar.gz"
x86_hash="$(prefetch_sri "$x86_url")"
arm_hash="$(prefetch_sri "$arm_url")"

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
sed -i -E \
  '/x86_64-linux = \{/,/};/ s|^([[:space:]]*hash = ")[^"]*(";)|\1'"${x86_hash}"'\2|' \
  "$package_file"
sed -i -E \
  '/aarch64-linux = \{/,/};/ s|^([[:space:]]*hash = ")[^"]*(";)|\1'"${arm_hash}"'\2|' \
  "$package_file"

if [ "$no_build" = false ]; then
  verify_package_build "$flake_dir" goose
fi

committed=true
log_info "Updated Goose: ${current_version} -> ${latest_version}"
