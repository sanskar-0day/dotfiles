{
  config,
  pkgs,
  unstable,
  lib,
  ...
}:
{
  imports = [
    ./shell.nix # Zsh + Starship
    ./git.nix # Git + Delta
    ./tools.nix # bat, fzf, zoxide, direnv, btop, tmux
    ./nvim.nix # Neovim (LazyVim)
    ./dev.nix # IDEs, Languages
  ];

  # User-specific packages
  home.packages = with pkgs; [
    firefox
    kdePackages.spectacle
    kdePackages.polkit-kde-agent-1
    kdePackages.plasma-nm ncdu
    nvtopPackages.full
    mesa-demos
    winboat
    freerdp
    unstable.antigravity
    fastfetch
    telegram-desktop
    vlc
    code-cursor
    windsurf


    # Nerd Fonts (required for icons in starship, eza, lazyvim)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Enable fontconfig for Home Manager fonts
  fonts.fontconfig.enable = true;

  # Fastfetch config (Sekiro-themed)
  xdg.configFile = {
    "fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
    "fastfetch/logo.txt".source = ./fastfetch/logo.txt;
    "fastfetch/ghost.png".source = ../../images/ghost.png;
  };

  # ── Wine .exe handler ─────────────────────────────────────────
  # Double-click any .exe → auto-creates prefix, installs deps, runs it
  xdg.desktopEntries.wine-run = {
    name = "Wine (Auto Prefix)";
    comment = "Run Windows .exe with auto prefix + DXVK";
    exec = "/home/sanskar/dotfiles/scripts/wine-run.sh %f";
    icon = "wine";
    terminal = false;
    type = "Application";
    categories = [ "Game" ];
    mimeType = [
      "application/x-ms-dos-executable"
      "application/x-msdos-program"
      "application/x-msdownload"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-ms-dos-executable" = [ "wine-run.desktop" ];
      "application/x-msdos-program" = [ "wine-run.desktop" ];
      "application/x-msdownload" = [ "wine-run.desktop" ];
      # Use Zen Browser (Flatpak) as the default browser
      "text/html" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/about" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/unknown" = [ "app.zen_browser.zen.desktop" ];
    };
  };

  # Force overwrite mimeapps.list (prevents HM clobbering errors)
  xdg.configFile."mimeapps.list".force = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Auto-map LM Studio's internal database directly to the user's permanent ~/models directory
  home.activation.linkLmStudioModels = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.cache/lm-studio
    ln -sfn ~/models ~/.cache/lm-studio/models
  '';

  # Home Manager state version
  home.stateVersion = "25.11";
}
