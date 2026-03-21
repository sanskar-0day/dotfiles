{
  config,
  pkgs,
  unstable,
  lib,
  ...
}:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./tools.nix
    ./nvim.nix
    ./dev.nix
    ./plasma.nix
  ];

  home.username = "sanskar";
  home.homeDirectory = "/home/sanskar";
  home.stateVersion = "25.11";

  # User-specific packages
  home.packages = with pkgs; [
    firefox
    unstable.lmstudio
    kdePackages.spectacle
    kdePackages.polkit-kde-agent-1
    kdePackages.plasma-nm
    ncdu
    nvtopPackages.full
    mesa-demos
    winboat
    unstable.antigravity
    fastfetch
    telegram-desktop
    vlc
    freerdp
    unstable.zed-editor-fhs
    unstable.code-cursor

    # Typst packages (managed via modules/typst.nix)
    typstPackages.cetz
    typstPackages.tbl
    typstPackages.tblr
    typstPackages.algo
    typstPackages.algorithmic
    typstPackages.lovelace
    typstPackages.codly
    typstPackages.finite
    typstPackages.bytefield
    typstPackages.plotst
    typstPackages.physica
    typstPackages.mitex
    typstPackages.fletcher
    typstPackages.pinit
    typstPackages.tasteful-pairings
    typstPackages.touying
    typstPackages.polylux
    typstPackages.diatypst
    typstPackages.grape-suite
    typstPackages.modern-cv
    typstPackages.clickworthy-resume
    typstPackages.brilliant-cv
    typstPackages.tablex
    typstPackages.showybox
    typstPackages.chicv
    typstPackages.academicv
    typstPackages.gviz
    typstPackages.tidy
    typstPackages.glossarium
    typstPackages.hydra
    typstPackages.typslides
    typstPackages.presentate
    typstPackages.minideck
    typstPackages.lineal
    typstPackages.leonux
    typstPackages.slydst
    typstPackages.gloat
    typstPackages.neat-cv
    typstPackages.toy-cv
    typstPackages.kiresume
    typstPackages.light-cv
    typstPackages.pesha
    typstPackages.imprecv
    typstPackages.porygon
    typstPackages.swe-cv
    typstPackages.chuli-cv
    typstPackages.mahou-cv
    typstPackages.equate
    typstPackages.ouset
    typstPackages.natrix
    typstPackages.ezchem
    typstPackages.eqalc
    typstPackages.scribe
    typstPackages.m-jaxon
    typstPackages.tinyset
    typstPackages.mannot
    typstPackages.ergo
    typstPackages.zebraw
    typstPackages.idwtet
    typstPackages.nassi
    typstPackages.wavy
    typstPackages.zap
    typstPackages.quill
    typstPackages.km
    typstPackages.atomic
    typstPackages.booktabs
    typstPackages.tablem
    typstPackages.pillar
    typstPackages.tabut
    typstPackages.tada
    typstPackages.spreet
    typstPackages.truthfy

    # ── Gaming & Performance ────────────────────────────────────
    protonup-qt
    protontricks
    mission-center

    # ── Terminal & Productivity ─────────────────────────────────
    unstable.ghostty
    obsidian
    hyperfine

    # Nerd Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;

  xdg.configFile = {
    # existing entries:
    "fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
    "fastfetch/logo.txt".source = ./fastfetch/logo.txt;
    "fastfetch/ghost.png".source = ../../images/ghost.png;
    "mimeapps.list".force = true;
  };

  # ── Shell & Terminal Tools ────────────────────────────────────
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
      style = "compact";
      show_preview = true;
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "dracula";
      default_layout = "compact";
      pane_frames = false;
    };
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

  programs.home-manager.enable = true;

  # Map LM Studio's internal database to ~/models
  home.activation.linkLmStudioModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.cache/lm-studio
    ln -sfn ~/models ~/.cache/lm-studio/models
  '';
}
