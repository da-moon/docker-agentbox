#!/usr/bin/env bash
set -euo pipefail

image_ref="${1:-agentbox:latest}"

docker run --rm "$image_ref" bash -lc '
  set -euo pipefail
  test "$(id -u)" = "1000"
  test "$(id -g)" = "1000"
  test "$HOME" = "/home/agent"
  test -w "$HOME"
  test -w /workspace

  for command_name in \
    claude codex hunk \
    rg fd sd jq yq bat fzf delta difft \
    git gh ssh curl wget \
    node bun python uv \
    gcc make cmake pkg-config \
    shellcheck shfmt biome prettier nixfmt \
    nix
  do
    command -v "$command_name" >/dev/null
  done

  claude --version
  codex --version
  hunk --help >/dev/null
  nix --version
  nix shell nixpkgs#hello -c hello
  nix profile add nixpkgs#hello
  "$HOME/.nix-profile/bin/hello"
'

docker run --rm \
  -e AGENT_UID=12345 \
  -e AGENT_GID=12345 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 12345 && test "$(id -g)" = 12345 && test -w /workspace'

docker run --rm \
  -e AGENT_GID=23456 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 1000 && test "$(id -g)" = 23456'

docker run --rm \
  -e AGENT_RUN_AS_ROOT=1 \
  "$image_ref" \
  bash -lc 'test "$(id -u)" = 0 && nix --version >/dev/null'
