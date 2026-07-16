{ pkgs, ... }:

let
  stripCoauthorHook = pkgs.writeShellScript "agentbox-strip-coauthor-commit-msg" ''
    # Strip all Co-authored-by trailers from commit messages.
    msg_file="$1"
    [ -f "$msg_file" ] || exit 0
    ${pkgs.gnused}/bin/sed -i '/^[[:space:]]*Co-authored-by:/Id' "$msg_file"
    exit 0
  '';
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;

    hooks = {
      commit-msg = stripCoauthorHook;
    };

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
