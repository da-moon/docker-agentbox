{
  description = "Self-contained Nix environment for Claude Code and Codex agent containers";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          claude-code = pkgs.callPackage ./nix/packages/claude-code.nix {
            inherit system;
          };
          codex = pkgs.callPackage ./nix/packages/codex.nix {
            inherit system;
          };
          hunk = pkgs.callPackage ./nix/packages/hunk.nix {
            inherit system;
          };

          agentbox-env = pkgs.buildEnv {
            name = "agentbox-env";
            paths = [
              claude-code
              codex
              hunk

              pkgs.bashInteractive
              pkgs.coreutils-full
              pkgs.findutils
              pkgs.gnused
              pkgs.gnugrep
              pkgs.gawk
              pkgs.which
              pkgs.file
              pkgs.less
              pkgs.procps
              pkgs.util-linux

              pkgs.cacert
              pkgs.curl
              pkgs.wget
              pkgs.git
              pkgs.git-lfs
              pkgs.gh
              pkgs.openssh

              pkgs.ripgrep
              pkgs.fd
              pkgs.sd
              pkgs.jq
              pkgs.yq-go
              pkgs.bat
              pkgs.fzf
              pkgs.delta
              pkgs.difftastic
              pkgs.tree

              pkgs.nodejs
              pkgs.bun
              pkgs.python3
              pkgs.uv

              pkgs.gcc
              pkgs.gnumake
              pkgs.cmake
              pkgs.pkg-config

              pkgs.shellcheck
              pkgs.shfmt
              pkgs.biome
              pkgs.prettier
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

              pkgs.shadow
              pkgs.su-exec
              pkgs.tini
            ];
            pathsToLink = [ "/bin" ];
          };
        in
        {
          default = agentbox-env;
          inherit
            agentbox-env
            claude-code
            codex
            hunk
            ;
        }
      );

      checks = forAllSystems (
        system:
        let
          packages = self.packages.${system};
        in
        {
          inherit (packages)
            agentbox-env
            claude-code
            codex
            hunk
            ;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.bash
              pkgs.curl
              pkgs.jq
              pkgs.nixfmt
              pkgs.shellcheck
            ];
          };
        }
      );
    };
}
