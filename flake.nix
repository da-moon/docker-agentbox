{
  description = "Self-contained Nix environment for Claude Code and Codex agent containers";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          clearUnfree = p: p.overrideAttrs (o: { meta = (o.meta or { }) // { license = [ ]; }; });

          harnessPackages = lib.mapAttrs (_: clearUnfree) {
            claude-code = pkgs.callPackage ./nix/packages/claude-code.nix { inherit system; };
            codex = pkgs.callPackage ./nix/packages/codex.nix { inherit system; };
            hunk = pkgs.callPackage ./nix/packages/hunk.nix { inherit system; };
            kimi-cli = pkgs.callPackage ./nix/packages/kimi-cli.nix { inherit system; };
            command-code = pkgs.callPackage ./nix/packages/command-code.nix { inherit system; };
            gsd-2 = pkgs.callPackage ./nix/packages/gsd-2.nix { inherit system; };
            fff-mcp = pkgs.callPackage ./nix/packages/fff-mcp.nix { inherit system; };
          };

          coreTools = [
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

            pkgs.shadow
            pkgs.su-exec
            pkgs.tini
          ];

          agentbox-extras = pkgs.buildEnv {
            name = "agentbox-extras";
            paths = [
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
            pathsToLink = [ "/bin" ];
          };

          harnessByCommand = lib.mapAttrs' (
            attr: pkg: lib.nameValuePair (pkg.meta.mainProgram or pkg.pname) attr
          ) harnessPackages;

          agentbox-manifest = pkgs.writeText "agentbox-harnesses.json" (builtins.toJSON harnessByCommand);

          agentbox-shim = pkgs.writeShellApplication {
            name = "agentbox-shim";
            runtimeInputs = [ ];
            text = "manifest=${agentbox-manifest}\n" + builtins.readFile ./nix/agentbox-shim.sh;
          };

          agentbox-shims = pkgs.runCommand "agentbox-shims" { } ''
            mkdir -p "$out/bin"
            for cmd in ${lib.escapeShellArgs (lib.attrNames harnessByCommand)}; do
              ln -s ${agentbox-shim}/bin/agentbox-shim "$out/bin/$cmd"
            done
          '';

          agentbox-base = pkgs.buildEnv {
            name = "agentbox-base";
            paths = coreTools ++ [ agentbox-shims ];
            pathsToLink = [ "/bin" ];
          };
        in
        {
          default = agentbox-base;
          inherit
            agentbox-base
            agentbox-extras
            ;
        }
        // harnessPackages
      );

      checks = forAllSystems (
        system:
        let
          packages = self.packages.${system};
        in
        {
          inherit (packages)
            agentbox-base
            agentbox-extras
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
