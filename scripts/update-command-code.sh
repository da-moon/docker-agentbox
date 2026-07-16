#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
# shellcheck source=scripts/lib/update-common.sh
source "${script_dir}/lib/update-common.sh"

readonly package_file="${repo_root}/nix/packages/command-code/default.nix"
readonly registry_url="https://registry.npmjs.org/command-code"
readonly placeholder_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

target_version=""
check_only=false
rehash=false
no_build=false

usage() {
  cat <<'EOF'
Usage: scripts/update-command-code.sh [OPTIONS]

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

require_commands curl jq nix sed

current_version="$(read_nix_version "$package_file")"
[ -n "$current_version" ] || {
  log_error "Could not read the current command-code version"
  exit 2
}

if [ -n "$target_version" ]; then
  latest_version="$target_version"
else
  latest_version="$(curl -fsSL "${registry_url}/latest" | jq -er '.version')"
fi
[ -n "$latest_version" ] || {
  log_error "Could not determine the target command-code version"
  exit 2
}

if [ "$check_only" = true ]; then
  if [ "$current_version" = "$latest_version" ]; then
    log_info "command-code is current (${current_version})"
    exit 0
  fi
  log_warn "command-code update available: ${current_version} -> ${latest_version}"
  exit 1
fi

if [ "$current_version" = "$latest_version" ] && [ "$rehash" = false ]; then
  log_info "command-code is already at ${current_version}"
  exit 0
fi

tarball_url="${registry_url}/-/command-code-${latest_version}.tgz"
tarball_hash="$(prefetch_sri "$tarball_url")"

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
  's|^([[:space:]]*hash = ")[^"]*(";)|\1'"${tarball_hash}"'\2|' \
  "$package_file"

sed -i -E \
  '/outputHashBySystem = \{/,/};/ s|^([[:space:]]*x86_64-linux = ")[^"]*(";)|\1'"${placeholder_hash}"'\2|' \
  "$package_file"
build_output="$(nix build "path:${repo_root}/nix#command-code" --no-link 2>&1 || true)"
output_hash="$(printf '%s\n' "$build_output" | sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' | head -n1)"
[ -n "$output_hash" ] || {
  log_error "Could not parse the recomputed x86_64-linux outputHash from the build output"
  printf '%s\n' "$build_output" >&2
  exit 1
}
sed -i -E \
  '/outputHashBySystem = \{/,/};/ s|^([[:space:]]*x86_64-linux = ")[^"]*(";)|\1'"${output_hash}"'\2|' \
  "$package_file"

if [ "$no_build" = false ]; then
  verify_package_build "$repo_root" command-code
fi

committed=true
log_info "Updated command-code: ${current_version} -> ${latest_version}"
