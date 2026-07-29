#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

image_name="${IMAGE_NAME:-agentbox}"
image_tag="${IMAGE_TAG:-latest}"
progress="${BUILDKIT_PROGRESS:-plain}"
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"

# A multi-platform image is a manifest list, which the local image store
# cannot hold - it can only be pushed to a registry. The default therefore
# pushes; set IMAGE_NAME to your repository first, e.g.
#   IMAGE_NAME=example.com/you/agentbox ./scripts/build.sh
# For a local, runnable image instead, pin a single platform:
#   PLATFORMS=linux/amd64 ./scripts/build.sh
host_platform="linux/amd64"
[ "$(uname -m)" = "aarch64" ] && host_platform="linux/arm64"
foreign="$(printf '%s' "$platforms" | tr ',' '\n' | grep -vx "$host_platform" || true)"
if [ -n "$foreign" ] && ! ls /proc/sys/fs/binfmt_misc/qemu-* >/dev/null 2>&1; then
  echo "build.sh: building for $foreign needs QEMU binfmt; install it once with:" >&2
  echo "  docker run --privileged --rm tonistiigi/binfmt --install all" >&2
  exit 1
fi

if [[ "$platforms" == *,* ]]; then
  builder="agentbox-multi"
  docker buildx inspect "$builder" >/dev/null 2>&1 \
    || docker buildx create --name "$builder" --driver docker-container >/dev/null
  exec docker buildx build \
    --builder "$builder" \
    --progress "$progress" \
    --platform "$platforms" \
    --push \
    --tag "${image_name}:${image_tag}" \
    "$@" \
    "$repo_root"
fi

exec docker buildx build \
  --progress "$progress" \
  --platform "$platforms" \
  --load \
  --tag "${image_name}:${image_tag}" \
  "$@" \
  "$repo_root"
