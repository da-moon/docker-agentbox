# Template for the per-user Home Manager flake. The entrypoint copies this
# directory to ~/.config/home-manager on first start, substituting
# @AGENTBOX_SYSTEM@ with the container's platform and injecting the image's
# flake.lock, so the flake in the home directory is directly evaluable and
# owned by the user.
{
  description = "Agentbox per-user Home Manager environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    {
      homeConfigurations.agent = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "@AGENTBOX_SYSTEM@"; };
        modules = [
          (import ./home.nix {
            username = "agent";
            homeDirectory = "/home/agent";
          })
        ];
      };
    };
}
