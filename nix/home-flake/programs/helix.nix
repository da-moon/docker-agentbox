{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    extraPackages = [
      pkgs.nushell
    ];
    settings = import ./helix-settings.nix;
    languages = import ./helix-languages.nix;
  };
}
