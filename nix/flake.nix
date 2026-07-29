{
  description = "Sandboxed LLM Harness container";

  # Flake input URLs must stay literal; Nix rejects computed input attrsets or
  # URLs here. Keep the nixpkgs and Home Manager release pins in sync manually.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
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

          clearUnfree =
            p:
            p.overrideAttrs (o: {
              meta = (o.meta or { }) // {
                license = [ ];
              };
            });

          harnessPackages = lib.mapAttrs (_: clearUnfree) (
            {
              claude-code = pkgs.callPackage ./packages/claude-code { inherit system; };
              codex = pkgs.callPackage ./packages/codex { inherit system; };
              hunk = pkgs.callPackage ./packages/hunk { inherit system; };
              goose = pkgs.callPackage ./packages/goose { inherit system; };
              omp = pkgs.callPackage ./packages/omp { inherit system; };
              kimi-cli = pkgs.callPackage ./packages/kimi-cli { inherit system; };
              command-code = pkgs.callPackage ./packages/command-code { inherit system; };
              gsd-2 = pkgs.callPackage ./packages/gsd-2 { inherit system; };
              fff-mcp = pkgs.callPackage ./packages/fff-mcp { inherit system; };
            }
            // lib.optionalAttrs (system == "x86_64-linux") {
              elio = pkgs.callPackage ./packages/elio { inherit system; };
            }
          );

          bootTools = [
            pkgs.bashInteractive
            pkgs.coreutils-full
            pkgs.gnused
            pkgs.cacert
            pkgs.shadow
            pkgs.su-exec

            home-manager.packages.${system}.home-manager
          ];

          # PID 1 and nix-daemon supervision; copied into the image rootfs by
          # the Dockerfile, not linked into the agentbox profile.
          s6-overlay = pkgs.callPackage ./packages/s6-overlay { inherit system; };

          harnessByCommand = lib.mapAttrs' (
            attr: pkg: lib.nameValuePair (pkg.meta.mainProgram or pkg.pname) attr
          ) harnessPackages;

          agentbox-manifest = pkgs.writeText "agentbox-harnesses.json" (builtins.toJSON harnessByCommand);

          # Plain list of harness command names. Baked into the image at
          # /opt/agentbox/harness-commands (see the Dockerfile), where
          # agentbox-setup reads it at container start to detect a stale base
          # profile on a reused /nix volume.
          agentbox-commands = pkgs.writeText "agentbox-harness-commands" (
            lib.concatStringsSep "\n" (lib.attrNames harnessByCommand) + "\n"
          );

          agentbox-shim = pkgs.writeShellApplication {
            name = "agentbox-shim";
            runtimeInputs = [
              pkgs.jq
              pkgs.util-linux
            ];
            text = "manifest=${agentbox-manifest}\n" + builtins.readFile ./agentbox-shim.sh;
          };

          agentbox-shims = pkgs.runCommand "agentbox-shims" { } ''
            mkdir -p "$out/bin"
            for cmd in ${lib.escapeShellArgs (lib.attrNames harnessByCommand)}; do
              ln -s ${agentbox-shim}/bin/agentbox-shim "$out/bin/$cmd"
            done
          '';

          agentbox-cli = pkgs.writeShellApplication {
            name = "agentbox";
            runtimeInputs = [
              pkgs.jq
              pkgs.curl
              pkgs.gnused
              pkgs.gnugrep
              pkgs.gawk
              pkgs.coreutils
            ];
            text = "manifest=${agentbox-manifest}\n" + builtins.readFile ./agentbox-cli.sh;
          };

          agentbox-base = pkgs.buildEnv {
            name = "agentbox-base";
            paths = bootTools ++ [
              agentbox-shims
              agentbox-cli
            ];
            pathsToLink = [ "/bin" ];
          };
        in
        {
          default = agentbox-base;
          inherit agentbox-base s6-overlay agentbox-commands;
        }
        // harnessPackages
      );

      checks = forAllSystems (
        system:
        let
          packages = self.packages.${system};
          homeFlakeOutputs = (import ./home-flake/flake.nix).outputs {
            inherit nixpkgs home-manager;
          };

          # Builds the same configuration the template in nix/home-flake
          # produces once the container's setup service instantiates it for
          # this system.
          home-agent =
            (builtins.getAttr "agent-${system}" homeFlakeOutputs.homeConfigurations).activationPackage;
        in
        {
          inherit (packages)
            agentbox-base
            s6-overlay
            claude-code
            codex
            hunk
            goose
            omp
            ;
          inherit (lib.optionalAttrs (system == "x86_64-linux") packages) elio;
          inherit home-agent;
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
