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

          harnessPackages = lib.mapAttrs (_: clearUnfree) {
            claude-code = pkgs.callPackage ./packages/claude-code.nix { inherit system; };
            codex = pkgs.callPackage ./packages/codex.nix { inherit system; };
            hunk = pkgs.callPackage ./packages/hunk.nix { inherit system; };
            goose = pkgs.callPackage ./packages/goose.nix { inherit system; };
            omp = pkgs.callPackage ./packages/omp.nix { inherit system; };
            kimi-cli = pkgs.callPackage ./packages/kimi-cli.nix { inherit system; };
            command-code = pkgs.callPackage ./packages/command-code.nix { inherit system; };
            gsd-2 = pkgs.callPackage ./packages/gsd-2.nix { inherit system; };
            fff-mcp = pkgs.callPackage ./packages/fff-mcp.nix { inherit system; };
          };

          bootTools = [
            pkgs.bashInteractive
            pkgs.coreutils-full
            pkgs.gnused
            pkgs.cacert
            pkgs.shadow
            pkgs.su-exec
            pkgs.tini

            home-manager.packages.${system}.home-manager
          ];

          harnessByCommand = lib.mapAttrs' (
            attr: pkg: lib.nameValuePair (pkg.meta.mainProgram or pkg.pname) attr
          ) harnessPackages;

          agentbox-manifest = pkgs.writeText "agentbox-harnesses.json" (builtins.toJSON harnessByCommand);

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

          agentbox-base = pkgs.buildEnv {
            name = "agentbox-base";
            paths = bootTools ++ [ agentbox-shims ];
            pathsToLink = [ "/bin" ];
          };
        in
        {
          default = agentbox-base;
          inherit agentbox-base;
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
          # produces once the entrypoint instantiates it for this system.
          home-agent =
            (builtins.getAttr "agent-${system}" homeFlakeOutputs.homeConfigurations).activationPackage;
        in
        {
          inherit (packages)
            agentbox-base
            claude-code
            codex
            hunk
            goose
            omp
            ;
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
