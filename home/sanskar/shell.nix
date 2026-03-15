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
      # nh rebuilds (Clean, fast, auto-diff)
      nrs    = "nh os switch ~/dotfiles";
      nrb    = "nh os boot ~/dotfiles && echo '✅ Boot entry added. Reboot to apply changes safely.'";
      nrt    = "nh os test ~/dotfiles";

      # Quick rebuild aliases (no nh)
      rs     = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
      rb     = "sudo nixos-rebuild boot --flake ~/dotfiles#nixos";
      rt     = "sudo nixos-rebuild test --flake ~/dotfiles#nixos";
      
      # Home Manager (No Rebuild Needed)
      hms = "home-manager switch --flake ~/dotfiles#sanskar";
      hmd = "home-manager dry-run --flake ~/dotfiles#sanskar";
      hmu = "home-manager switch --flake ~/dotfiles#sanskar --update-input nixpkgs";

      # GPU Offloading
      nv-run = "nvidia-offload";
      nv-game = "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only";
      
      # High Performance Steam Launch Options
      steam-perf = "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only gamemoderun mangohud %command%";
      perf-run   = "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only gamemoderun";

      # AI Infrastructure
      opencode = "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH /run/current-system/sw/bin/opencode";

      # Modern CLI replacements
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -l --icons --group-directories-first --git";
      la  = "eza -la --icons --group-directories-first --git";
      lt  = "eza --tree --level=2 --icons";
      cat = "bat --style=auto";
      df  = "duf";
      du  = "dust";
      ps  = "procs";
      top = "btop";

      # Safety
      rm = "trash-put";
      cp = "cp -iv";
      mv = "mv -iv";

      # Git shortcuts
      g   = "git";
      gs  = "git status -sb";
      gd  = "git diff";
      gp  = "git push";
      gl  = "git pull";
      gco = "git checkout";
      gcm = "git commit -m";
      lazyg = "lazygit";

      # ── Gaming ───────────────────────────────────────────────
      # Disable Kanata (removes Home Row Mods for WASD gaming)
      game-on  = "sudo systemctl stop kanata-default.service && echo '🎮 Game Mode: ON (Kanata Disabled)'";
      # Enable Kanata (restores Home Row Mods for typing)
      game-off = "sudo systemctl start kanata-default.service && echo '⌨️  Game Mode: OFF (Kanata Enabled)'";

      # Documentation
      build-pdf = "typst compile ~/dotfiles/README.typ ~/dotfiles/README.pdf && echo '📄 PDF Generated at ~/dotfiles/README.pdf'";
      kanata-help = "grep -A 50 'Kanata Keyboard Remapping Guide' ~/dotfiles/README.md";

      # Misc
      cls   = "clear";
      myip  = "curl -s ifconfig.me";
      bt-fix = "sudo rfkill unblock bluetooth && sudo systemctl restart bluetooth && bluetoothctl power on";
    };

    initContent = builtins.readFile ./zshrc;
  };

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
