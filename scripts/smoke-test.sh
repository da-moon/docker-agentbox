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
    rg fd sd jq yq bat fzf delta hx clear \
    atuin zellij \
    git gh ssh curl wget \
    shellcheck shfmt nixfmt nix
  do
    command -v "$command_name" >/dev/null
  done

  profile="$HOME/.local/state/nix/profiles/agentbox"
  harnesses=(claude codex hunk goose omp kimi command-code gsd fff-mcp)
  if [ "$(uname -m)" = "x86_64" ]; then
    harnesses+=(elio)
  fi
  for command_name in "${harnesses[@]}"; do
    command -v "$command_name" >/dev/null
  done
  test ! -e "$profile/bin/claude"
  test ! -e "$profile/bin/codex"
  test ! -e "$profile/bin/goose"
  test ! -e "$profile/bin/omp"

  for command_name in node bun python3 uv gcc make cmake pkg-config biome prettier difft; do
    command -v "$command_name" >/dev/null
  done

  nix --version
  hunk --version >/dev/null 2>&1
  test -x "$profile/bin/hunk"

  command -v home-manager >/dev/null
  test "$EDITOR" = "hx"
  test "$VISUAL" = "hx"
  test -e "$HOME/.config/helix/config.toml"
  test -e "$HOME/.config/helix/languages.toml"
  test -e "$HOME/.config/zellij/config.kdl"
  zellij setup --check >/dev/null
  grep -q "line-number = \"relative\"" "$HOME/.config/helix/config.toml"
  grep -q "command = \"vtsls\"" "$HOME/.config/helix/languages.toml"
  grep -q "show_startup_tips false" "$HOME/.config/zellij/config.kdl"
  test -w "$HOME/.config/home-manager/flake.nix"
  test -w "$HOME/.config/home-manager/flake.lock"
  test -w "$HOME/.config/home-manager/programs/helix.nix"
  test -w "$HOME/.config/home-manager/programs/zellij.nix"
  test -w "$HOME/.config/home-manager/programs/helix-settings.nix"
  test -w "$HOME/.config/home-manager/programs/helix-languages.nix"
  test -w "$HOME/.config/home-manager/programs/zellij-settings.nix"
  grep -q "theme = \"nord\"" "$HOME/.config/home-manager/programs/helix-settings.nix"
  grep -q "vtsls = {" "$HOME/.config/home-manager/programs/helix-languages.nix"
  grep -q "zellij_forgot.wasm" "$HOME/.config/home-manager/programs/zellij-settings.nix"
  grep -q "nixos-unstable" "$HOME/.config/home-manager/flake.lock"
  test ! -e "$HOME/.config/home-manager/home.nix"
  grep -q "alias -- hm-switch=" "$HOME/.bashrc"
  grep -q "alias -- hm-update=" "$HOME/.bashrc"
  test -w "$HOME/.claude/settings.json"
  test "$(jq -r .permissions.defaultMode "$HOME/.claude/settings.json")" \
    = "auto"
  test "$(jq -r .autoMemoryDirectory "$HOME/.claude/settings.json")" = "null"
  grep -qx "approval_policy = \"never\"" "$HOME/.codex/config.toml"
  grep -qx "default_permission_mode = \"yolo\"" "$HOME/.kimi-code/config.toml"

  test -e "$HOME/.commandcode/settings.json"
  test -x "$HOME/.commandcode/hooks/strip-coauthor.sh"
  grep -q "strip-coauthor.sh" "$HOME/.commandcode/settings.json"
  git_hooks_path=$(git config --global core.hooksPath)
  test -n "$git_hooks_path"
  test -x "$git_hooks_path/commit-msg"
'

docker run --rm -v "$store_volume:/nix" -v "$workspace_dir:/workspace" \
  "$image_ref" \
  bash -lc '
    set -euo pipefail
    test -O "$HOME/.claude/settings.json"
    test "$(jq -r .autoMemoryDirectory "$HOME/.claude/settings.json")" \
      = "/workspace/.claude/memory"
  '

docker run --rm -v "$store_volume:/nix" "$image_ref" sh -c '
  test "$EDITOR" = hx
  test "$VISUAL" = hx
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
