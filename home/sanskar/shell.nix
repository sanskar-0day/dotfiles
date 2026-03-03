{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      # NixOS rebuild shortcuts
      nrs  = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
      nrt  = "sudo nixos-rebuild test --flake ~/dotfiles#nixos";
      nrvm = "nixos-rebuild build-vm --flake ~/dotfiles#nixos";
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";

      # eza (better ls)
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -la --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";

      # bat (better cat)
      cat = "bat --style=auto";

      # Safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Quick dirs
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    initContent = ''
      # Starship prompt
      eval "$(starship init zsh)"

      # Edit command line in $EDITOR with Ctrl-E
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^e" edit-command-line

      # ── Rich Completions ──────────────────────────────────────
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
      zstyle ':completion:*:warnings' format '%F{red}No matches%f'
      zstyle ':completion:*' squeeze-slashes true
      zstyle ':completion:*' complete-options true

      # Accept autosuggestion with Ctrl-Space
      bindkey '^ ' autosuggest-accept

      # Fastfetch on launch (only in interactive, non-tmux shells)
      if [[ -z "$TMUX" && $- == *i* ]]; then
        fastfetch
      fi
    '';
  };

  # SSH agent (remembers SSH key passwords)
  services.ssh-agent.enable = true;

  # Carapace – completions for 1000+ CLI tools
  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  # nix-index – "command not found" suggestions for nix packages
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      directory.truncation_length = 3;
      git_branch.symbol = " ";
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };
}
