{
  programs.bash = {
    enable = true;
    shellAliases = {
      hm-switch = "home-manager switch -b backup --flake ~/.config/home-manager#agent";
      hm-update = "nix flake update --flake ~/.config/home-manager && home-manager switch -b backup --flake ~/.config/home-manager#agent";
    };
  };
}
