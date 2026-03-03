{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Sanskar-0day";
      user.email = "sanskarbalpande@gmail.com";
      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate -20";
        undo = "reset --soft HEAD~1";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      core.editor = "nvim";
    };
  };

  # ── delta (better diffs) ──────────────────────────────────────
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };
  # GitHub CLI
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    extensions = [ pkgs.gh-dash ];
    gitCredentialHelper.enable = true;
  };
}
