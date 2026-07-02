# Home Manager module for the container user. The entrypoint copies this
# flake to ~/.config/home-manager on first start and applies it with
# home-manager switch; edit it there and re-run home-manager switch to change
# the environment. AGENTBOX_HM_FLAKE replaces it wholesale with a
# user-provided flake reference.
{ username, homeDirectory }:
{ pkgs, lib, ... }:
let
  # Container defaults for the agent harnesses. Approval prompts are disabled
  # because the container is the sandbox, and commit/PR attribution is turned
  # off everywhere.
  claudeSettings = pkgs.writeText "agentbox-claude-settings.json" (
    builtins.toJSON {
      permissions.defaultMode = "bypassPermissions";
      skipDangerousModePermissionPrompt = true;
      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };
      alwaysThinkingEnabled = true;
      effortLevel = "xhigh";
      env.DISABLE_AUTOUPDATER = "1";
    }
  );

  codexConfig = pkgs.writeText "agentbox-codex-config.toml" ''
    approval_policy = "never"
    sandbox_mode = "danger-full-access"
    preferred_auth_method = "apikey"
    commit_attribution = ""
  '';

  kimiConfig = pkgs.writeText "agentbox-kimi-config.toml" ''
    default_permission_mode = "yolo"
  '';

  # The binary is nix-pinned, so its self-updater is pure churn.
  kimiTui = pkgs.writeText "agentbox-kimi-tui.toml" ''
    [upgrade]
    auto_install = false
  '';
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # The development packages installed at container start. Extend this list,
  # or point AGENTBOX_HM_FLAKE at your own flake to replace it.
  home.packages = [
    pkgs.nodejs
    pkgs.bun
    pkgs.python3
    pkgs.uv
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake
    pkgs.pkg-config
    pkgs.biome
    pkgs.prettier
    pkgs.difftastic
  ];

  # Harness configs are seeded as mutable copies rather than home.file
  # symlinks: the harnesses rewrite their own config files at runtime (codex
  # stores trust state and hook hashes; claude persists plugin and permission
  # grants), which a read-only store symlink would break. Each file is written
  # only when absent; delete it to get the default back on the next start.
  home.activation.agentboxHarnessDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.claude/settings.json" ]; then
      mkdir -p "$HOME/.claude"
      extra='{}'
      if ${pkgs.util-linux}/bin/mountpoint -q /workspace; then
        extra='{"autoMemoryDirectory": "/workspace/.claude/memory"}'
      fi
      ${pkgs.jq}/bin/jq --argjson extra "$extra" '. + $extra' \
        ${claudeSettings} >"$HOME/.claude/settings.json"
    fi
    if [ ! -e "$HOME/.codex/config.toml" ]; then
      mkdir -p "$HOME/.codex"
      install -m 0644 ${codexConfig} "$HOME/.codex/config.toml"
    fi
    if [ ! -e "$HOME/.kimi-code/config.toml" ]; then
      mkdir -p "$HOME/.kimi-code"
      install -m 0644 ${kimiConfig} "$HOME/.kimi-code/config.toml"
    fi
    if [ ! -e "$HOME/.kimi-code/tui.toml" ]; then
      mkdir -p "$HOME/.kimi-code"
      install -m 0644 ${kimiTui} "$HOME/.kimi-code/tui.toml"
    fi
  '';
}
