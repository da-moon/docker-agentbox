{
  programs.zellij = {
    enable = true;
    settings = import ./zellij-settings.nix;
  };
}
