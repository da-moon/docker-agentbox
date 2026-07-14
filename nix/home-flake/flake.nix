# Template for the per-user Home Manager flake. The entrypoint copies this
# file, flake.lock, and programs/ to ~/.config/home-manager on first start,
# substituting @AGENTBOX_SYSTEM@ with the container's platform, so the flake in
# the home directory is directly evaluable and owned by the user.
{
  description = "Agentbox per-user Home Manager environment";

  # Flake input URLs must stay literal; Nix rejects computed input attrsets or
  # URLs here. Keep the nixpkgs and Home Manager release pins in sync manually.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable ? nixpkgs,
      home-manager,
      ...
    }:
    let
      mkHomeModule =
        {
          username,
          homeDirectory,
        }:
        {
          config,
          pkgs,
          lib,
          pkgsUnstable ? pkgs,
          ...
        }:
        let
          # Container defaults for the agent harnesses. Approval prompts are
          # disabled because the container is the sandbox, and commit/PR
          # attribution is turned off everywhere.
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
            [thinking]
            enabled = true
            effort = "xhigh"
          '';

          # The binary is nix-pinned, so its self-updater is pure churn.
          kimiTui = pkgs.writeText "agentbox-kimi-tui.toml" ''
            [upgrade]
            auto_install = false
          '';
        in
        {
          imports = [ ./programs ];

          home.username = username;
          home.homeDirectory = homeDirectory;
          # Derived from Home Manager's release.json, so the seeded state
          # version follows release-26.05 without a second hard-coded value.
          home.stateVersion = config.home.version.release;

          home.sessionVariables = {
            EDITOR = "hx";
            VISUAL = "hx";
            COLORTERM= "truecolor" ;
          };

          # The packages installed at container start. pkgs follows the
          # release pinned above.
          # use pkgsUnstable.<name> for individual packages from
          # nixos-unstable. Edit this list inside
          # ~/.config/home-manager/flake.nix and run hm-switch to change the
          # environment for this container.
          home.packages = [
            pkgs.findutils
            pkgs.gnused
            pkgs.gnugrep
            pkgs.gawk
            pkgs.which
            pkgs.file
            pkgs.less
            pkgs.ncurses
            pkgs.procps
            pkgs.util-linux

            pkgs.curl
            pkgs.wget
            pkgs.gitMinimal
            pkgs.git-lfs
            pkgs.gh
            pkgs.hut
            pkgs.glab
            pkgs.openssh

            pkgs.fd
            pkgs.sd
            pkgs.yq-go
            pkgs.delta
            pkgs.tree

            pkgs.shellcheck
            pkgs.shfmt
            pkgs.nixfmt

            pkgs.gnupatch
            pkgs.gnutar
            pkgs.gzip
            pkgs.bzip2
            pkgs.xz
            pkgs.zstd
            pkgs.unzip
            pkgs.zip
            pkgs.rsync

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
          # symlinks: the harnesses rewrite their own config files at runtime
          # (codex stores trust state and hook hashes; claude persists plugin
          # and permission grants), which a read-only store symlink would
          # break. Each file is written only when absent; delete it to get the
          # default back on the next start.
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
        };

      mkHomeConfiguration =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {
            pkgsUnstable = import nixpkgs-unstable { inherit system; };
          };
          modules = [
            (mkHomeModule {
              username = "agent";
              homeDirectory = "/home/agent";
            })
          ];
        };
    in
    {
      homeModules.agentbox = mkHomeModule;

      homeConfigurations = {
        agent = mkHomeConfiguration "@AGENTBOX_SYSTEM@";
        agent-x86_64-linux = mkHomeConfiguration "x86_64-linux";
        agent-aarch64-linux = mkHomeConfiguration "aarch64-linux";
      };
    };
}
