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

  home.username = "sanskar";
  home.homeDirectory = "/home/sanskar";

  # User-specific packages
  home.packages = with pkgs; [
    firefox
    kdePackages.spectacle
    kdePackages.polkit-kde-agent-1
    kdePackages.plasma-nm ncdu
    nvtopPackages.full
    mesa-demos
    winboat
    unstable.antigravity
    fastfetch
    unstable.zed-editor-fhs

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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
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
