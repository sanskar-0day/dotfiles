{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Basic Zsh Options
    defaultKeymap = "emacs";
    dotDir = "${config.xdg.configHome}/zsh";

    # History configuration (100k entries)
    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      expireDuplicatesFirst = true;
      extended = true;
    };

    setOptions = [
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"
      "INTERACTIVE_COMMENTS"
      "NO_BEEP"
      "COMBINING_CHARS"
      "NUMERIC_GLOB_SORT"
      "NOMATCH"
      "HASH_LIST_ALL"
      "ALWAYS_TO_END"
      "COMPLETE_ALIASES"
      "AUTO_MENU"
      "AUTO_PARAM_SLASH"
    ];

    shellAliases = {
      # ── System Maintenance ──────────────────────────────────────────────
      nrs = "nh os switch ~/dotfiles";
      nrb = "nh os boot ~/dotfiles";
      nrt = "nh os test ~/dotfiles";
      hms = "home-manager switch --flake ~/dotfiles#sanskar";
      hmu = "home-manager switch --flake ~/dotfiles#sanskar --update-input nixpkgs";
      nixgc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";

      # ── Development & GPU ───────────────────────────────────────────────
      nv-run = "nvidia-offload";
      nv-game = "nvidia-offload gamemoderun";
      perf-run = "nvidia-offload gamemoderun mangohud";
      
      # ── Steam & Games ───────────────────────────────────────────────────
      # Launch Steam on the NVIDIA GPU (solves many game startup issues)
      steam-nv = "nvidia-offload steam";
      # Launch a FitGirl / Repack game easily
      repack-run = "nvidia-offload steam-run wine";
      
      # Copy this line into Steam -> Properties -> Launch Options for any lagging game:
      # gamemoderun nvidia-offload mangohud %command%
      
      opencode = "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH /run/current-system/sw/bin/opencode";

      # ── Modern Replacements (Core Tools) ────────────────────────────────
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --git";
      la = "eza -la --icons --group-directories-first --git";
      lt = "eza --tree --level=2 --icons";
      cat = "bat --style=auto";
      df = "duf";
      du = "dust";
      ps = "procs";
      top = "btop";
      grep = "rg";
      sed = "sd";
      hexdump = "hexyl";

      # ── Safety & Quality of Life ────────────────────────────────────────
      rm = "trash-put";
      cp = "cp -iv";
      mv = "mv -iv";
      mkdir = "mkdir -pv";
      cls = "clear";
      q = "exit";
      path = "echo $PATH | tr ':' '\\n' | nl";

      # ── Git Shortcuts ───────────────────────────────────────────────────
      g = "git";
      gs = "git status -sb";
      gd = "git diff";
      gl = "git pull";
      gp = "git push";
      gco = "git checkout";
      gcm = "git commit -m";
      glog = "git log --oneline --graph --decorate -20";
      lazyg = "lazygit";

      # ── Quick Navigation ────────────────────────────────────────────────
      ".." = "cd ..";
      "..." = "cd ../..";
      dots = "cd ~/dotfiles";
      conf = "cd ~/dotfiles && $EDITOR .";

      # ── Typst & Documentation ───────────────────────────────────────────
      pdf = "typst compile";
      build-docs = "nix build ~/dotfiles#docs && cp result/config-reference.pdf ~/dotfiles/docs/ && echo 'Config reference built.'";

      # ── Networking & Bluetooth ──────────────────────────────────────────
      wifi-status = "nmcli device status";
      wifi-list = "nmcli device wifi list";
      wifi-audit = "nmcli device show wlan0 && nmcli connection show --active && resolvectl status";
      
      # ── Kanata Control ──────────────────────────────────────────────────
      game-on = "sudo systemctl stop kanata-default.service && notify-send 'Keyboard' 'Gaming Mode (Kanata OFF)'";
      game-off = "sudo systemctl start kanata-default.service && notify-send 'Keyboard' 'Typing Mode (Kanata ON)'";

      # Reset Bluetooth and Audio stack (Fixes "Visible but not connecting")
      bt-fix = "sudo rfkill unblock bluetooth && sudo systemctl restart bluetooth && systemctl --user restart pipewire wireplumber && bluetoothctl power on && echo 'Bluetooth and Audio stack reset. Try connecting now.'";
      # Complete reset (unpairs all devices — use as last resort)
      bt-clean = "bluetoothctl devices | cut -f2 -d' ' | xargs -I{} bluetoothctl remove {} && bt-fix";
    };

    # External scripts/hooks and main configuration
    initContent = ''
      # Atuin History Search
      if command -v atuin &>/dev/null; then
        eval "$(atuin init zsh --disable-up-arrow)"
      fi

      # Starship Prompt
      if command -v starship &>/dev/null; then
        eval "$(starship init zsh)"
      fi

      ${builtins.readFile ./zshrc}
    '';
  };

  # ── Starship Prompt ────────────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      scan_timeout = 10;
      format = "$directory$git_branch$git_status$nix_shell$character";

      character = {
        success_symbol = "[󱄅](bold green) ";
        error_symbol = "[󱄅](bold red) ";
        vicmd_symbol = "[󱄅](bold purple) ";
      };

      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold cyan";
        read_only = " 󰌾";
      };

      git_branch = {
        symbol = "󰊢 ";
        style = "bold purple";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bold yellow";
        modified = "󰏫 ";
        staged = "󰐖 ";
        renamed = "󰑕 ";
        deleted = "󰗨 ";
      };

      nix_shell = {
        symbol = "󱄅 ";
        style = "bold blue";
        format = "via [$symbol]($style) ";
      };
    };
  };
}
