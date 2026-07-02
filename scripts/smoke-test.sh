#!/usr/bin/env bash
set -euo pipefail

image_ref="${1:-agentbox:latest}"
store_volume="agentbox-smoke-$$"
workspace_dir="$(mktemp -d)"

cleanup() {
  docker volume rm -f "$store_volume" >/dev/null 2>&1 || true
  rm -rf "$workspace_dir"
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

  command -v home-manager >/dev/null
  test -w "$HOME/.config/home-manager/home.nix"
  test -w "$HOME/.claude/settings.json"
  test "$(jq -r .permissions.defaultMode "$HOME/.claude/settings.json")" \
    = "bypassPermissions"
  test "$(jq -r .autoMemoryDirectory "$HOME/.claude/settings.json")" = "null"
  grep -qx "approval_policy = \"never\"" "$HOME/.codex/config.toml"
  grep -qx "default_permission_mode = \"yolo\"" "$HOME/.kimi-code/config.toml"
'

docker run --rm -v "$store_volume:/nix" -v "$workspace_dir:/workspace" \
  "$image_ref" \
  bash -lc '
    set -euo pipefail
    test -O "$HOME/.claude/settings.json"
    test "$(jq -r .autoMemoryDirectory "$HOME/.claude/settings.json")" \
      = "/workspace/.claude/memory"
  '

docker run --rm -v "$store_volume:/nix" \
  -e AGENT_UID=12345 -e AGENT_GID=12345 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 12345 && test "$(id -g)" = 12345 && test -w /workspace'

docker run --rm -v "$store_volume:/nix" \
  -e AGENT_GID=23456 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 1000 && test "$(id -g)" = 23456'

if docker run --rm -v "$store_volume:/nix" -e AGENT_UID=0 "$image_ref" true 2>/dev/null; then
  echo "AGENT_UID=0 unexpectedly accepted" >&2
  exit 1
fi
