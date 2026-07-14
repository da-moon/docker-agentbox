{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;

    extraConfig = {
      core = {
        autocrlf = false;
        symlinks = true;
      };

      pull.rebase = true;
      rebase.autoStash = true;
      fetch.prune = true;
      push.recurseSubmodules = "on-demand";
      init.defaultBranch = "main";

      # Clear any inherited credential helpers, then use the CLI-native helpers.
      credential."https://github.com".helper = [ "" "!gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!gh auth git-credential" ];
      credential."https://gitlab.com".helper = [ "" "!glab auth git-credential" ];
    };
  };
}
