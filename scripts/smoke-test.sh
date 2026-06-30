#!/usr/bin/env bash
set -euo pipefail

image_ref="${1:-agentbox:latest}"
store_volume="agentbox-smoke-$$"

cleanup() {
  docker volume rm -f "$store_volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT
docker volume create "$store_volume" >/dev/null

docker run --rm -v "$store_volume:/nix" "$image_ref" bash -lc '
  set -euo pipefail
  test "$(id -u)" = "1000"
  test "$(id -g)" = "1000"
  test "$HOME" = "/home/agent"
  test -w "$HOME"
  test -w /workspace

  for command_name in \
    rg fd sd jq yq bat fzf delta \
    git gh ssh curl wget \
    shellcheck shfmt nixfmt nix
  do
    command -v "$command_name" >/dev/null
  done

  profile="$HOME/.local/state/nix/profiles/agentbox"
  for command_name in claude codex hunk kimi command-code gsd fff-mcp; do
    command -v "$command_name" >/dev/null
  done
  test ! -e "$profile/bin/claude"
  test ! -e "$profile/bin/codex"

  for command_name in node bun python3 uv gcc make cmake pkg-config biome prettier difft; do
    command -v "$command_name" >/dev/null
  done

  nix --version
  hunk --help >/dev/null
  test -x "$profile/bin/hunk"
'

docker run --rm -v "$store_volume:/nix" \
  -e AGENT_UID=12345 -e AGENT_GID=12345 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 12345 && test "$(id -g)" = 12345 && test -w /workspace'

docker run --rm -v "$store_volume:/nix" \
  -e AGENT_GID=23456 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 1000 && test "$(id -g)" = 23456'

docker run --rm -v "$store_volume:/nix" \
  -e AGENT_RUN_AS_ROOT=1 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 0 && command -v node >/dev/null && nix --version >/dev/null'
