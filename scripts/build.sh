#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

image_name="${IMAGE_NAME:-agentbox}"
image_tag="${IMAGE_TAG:-latest}"
progress="${BUILDKIT_PROGRESS:-plain}"

exec docker build \
  --progress "$progress" \
  --tag "${image_name}:${image_tag}" \
  "$@" \
  "$repo_root"
