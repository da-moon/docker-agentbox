#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
# shellcheck source=scripts/lib/update-common.sh
source "${script_dir}/lib/update-common.sh"

readonly flake_dir="${AGENTBOX_FLAKE_DIR:-${repo_root}/nix}"
readonly package_file="${flake_dir}/packages/hunk/default.nix"
readonly releases_url="https://github.com/modem-dev/hunk/releases/latest"

target_version=""
target_tag=""
check_only=false
rehash=false
no_build=false

usage() {
  cat <<'EOF'
Usage: scripts/update-hunk.sh [OPTIONS]

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
  log_error "Could not read the current Hunk version"
  exit 2
}

if [ -n "$target_tag" ]; then
  latest_tag="$target_tag"
  latest_version="${latest_tag#v}"
elif [ -n "$target_version" ]; then
  latest_version="$target_version"
  latest_tag="v${latest_version}"
else
  effective_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$releases_url")"
  latest_tag="${effective_url##*/}"
  latest_version="${latest_tag#v}"
fi

if [ "$check_only" = true ]; then
  if [ "$current_version" = "$latest_version" ]; then
    log_info "Hunk is current (${current_version})"
    exit 0
  fi
  log_warn "Hunk update available: ${current_version} -> ${latest_version}"
  exit 1
fi

if [ "$current_version" = "$latest_version" ] && [ "$rehash" = false ]; then
  log_info "Hunk is already at ${current_version}"
  exit 0
fi

x86_url="https://github.com/modem-dev/hunk/releases/download/${latest_tag}/hunkdiff-linux-x64.tar.gz"
arm_url="https://github.com/modem-dev/hunk/releases/download/${latest_tag}/hunkdiff-linux-arm64.tar.gz"
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
  verify_package_build "$flake_dir" hunk
fi

committed=true
log_info "Updated Hunk: ${current_version} -> ${latest_version}"
