{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;

    # Per-user identity: uncomment and fill in after launching the container,
    # or set via `git config --global user.name` / `git config --global user.email`.
    # userName = "";
    # userEmail = "";

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
