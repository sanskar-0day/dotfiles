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
      # nrb uses boot mode (safe — no display crash) + activates on next reboot
      nrb    = "sudo nixos-rebuild boot --flake ~/dotfiles#nixos --fallback && echo '✅ Installed. Reboot to activate.'";
      # nrs does a live switch (may briefly reset display on NVIDIA)
      nrs    = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos --fallback";
      nrt    = "sudo nixos-rebuild test --flake ~/dotfiles#nixos --fallback";
      nrvm   = "nixos-rebuild build-vm --flake ~/dotfiles#nixos --fallback";
      nup    = "nix flake update ~/dotfiles && nrs";
      ndiff  = "nvd diff /run/current-system result";
      nlog   = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nroll  = "sudo nixos-rebuild switch --rollback";
      nclean = "sudo nix-collect-garbage -d && nix-collect-garbage -d && sudo nix-store --optimise";
      nwhy   = "nix why-depends /run/current-system";

      # ── AI Infrastructure Wrappers ───────────────────────────
      # Fix OpenCode plugins (e.g. sharp/Antigravity) natively crashing due to missing C++ bindings
      opencode = "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:\$LD_LIBRARY_PATH /run/current-system/sw/bin/opencode";

      # ── Modern CLI replacements ──────────────────────────────
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -l --icons --group-directories-first --git";
      la  = "eza -la --icons --group-directories-first --git";
      lt  = "eza --tree --level=2 --icons";
      lta = "eza --tree --level=3 --icons -a";

      cat = "bat --style=auto";
      df  = "duf";
      du  = "dust";
      ps  = "procs";
      dig = "dog";
      top = "btop";

      # ── Safety ───────────────────────────────────────────────
      rm = "trash-put";
      cp = "cp -iv";
      mv = "mv -iv";
      mkdir = "mkdir -pv";

      # ── Quick dirs ───────────────────────────────────────────
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";
      "~"    = "cd ~";
      "-"    = "cd -";

      # ── Git shortcuts ────────────────────────────────────────
      g   = "git";
      gs  = "git status -sb";
      gd  = "git diff";
      gp  = "git push";
      gl  = "git pull";
      gco = "git checkout";
      gcm = "git commit -m";
      gca = "git commit --amend --no-edit";
      glog = "git log --oneline --graph --decorate -20";
      lg  = "lazygit";

      # ── Misc ─────────────────────────────────────────────────
      cls   = "clear";
      help  = "tldr";
      ping  = "ping -c 5";
      myip  = "curl -s ifconfig.me";
      ports = "sudo ss -tulnp";
    };

    initContent = ''
      # ── Environment Variables ─────────────────────────────────
      export FLAKE="$HOME/dotfiles"  # Used by `nh` (Nix Helper) automatically

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

      # ── Fuzzy Nix Package Search ──────────────────────────────
      # ns <query>  → fuzzy search stable packages
      # nu <query>  → fuzzy search unstable packages
      # ni <query>  → install a package temporarily with nix shell
      ns() {
        nix search nixpkgs#"$1" --json 2>/dev/null \
          | ${pkgs.jq}/bin/jq -r 'to_entries[] | "\(.key)\t\(.value.description)"' \
          | column -t -s $'\t' \
          | ${pkgs.fzf}/bin/fzf --ansi --preview 'echo {}' --header "Stable Packages (25.11)"
      }

      nu() {
        nix search github:NixOS/nixpkgs/nixos-unstable#"$1" --json 2>/dev/null \
          | ${pkgs.jq}/bin/jq -r 'to_entries[] | "\(.key)\t\(.value.description)"' \
          | column -t -s $'\t' \
          | ${pkgs.fzf}/bin/fzf --ansi --preview 'echo {}' --header "Unstable Packages"
      }

      ni() {
        nix shell nixpkgs#"$1"
      }

      # ── Quick Edit Dotfiles ───────────────────────────────────
      dots() {
        cd ~/dotfiles && $EDITOR .
      }

      # ── Standalone Gemini CLI Multi-Account Swapper ───────────
      swap-gemini() {
        if [ -z "$1" ]; then
          echo "Usage: swap-gemini <profile_name>"
          echo "Example: swap-gemini personal"
          return 1
        fi
        
        # Swaps OAuth credential files by symlinking them to the default location
        local profile_file="$HOME/.config/gemini/profiles/$1.json"
        local active_file="$HOME/.config/gemini/credentials.json"
        
        if [ -f "$profile_file" ]; then
          ln -sf "$profile_file" "$active_file"
          echo "🔄 Swapped Gemini OAuth session to profile: $1"
        else
          echo "❌ OAuth profile not found at $profile_file"
          echo "To create it: First run 'gemini login', then 'mv ~/.config/gemini/credentials.json ~/.config/gemini/profiles/$1.json'"
        fi
      }

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
