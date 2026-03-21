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

  # ── User-Specific Packages ────────────────────────────────────
  home.packages = with pkgs; [
    # ── Internet & Communication ──
    firefox
    telegram-desktop
    vlc
    freerdp

    # ── Desktop & System ──
    kdePackages.spectacle # Screenshots
    kdePackages.polkit-kde-agent-1
    kdePackages.plasma-nm # Network applet
    ncdu # TUI disk usage
    nvtopPackages.full # GPU monitor
    mesa-demos 
    fastfetch # System info

    # ── Gaming & Graphics ──
    protonup-qt
    protontricks
    mission-center # Benchmarking/Resources

    # ── Terminal & Productivity ──
    unstable.ghostty # Pro terminal
    obsidian # Notes
    hyperfine # CLI benchmark
    yazi # TUI file manager
    unstable.lmstudio # AI 모델링
    unstable.antigravity # Agentic AI
    unstable.zed-editor-fhs
    unstable.code-cursor

    # ── Typst Ecosystem (Architecture documented in modules/typst.nix) ──
    typstPackages.cetz typstPackages.tbl typstPackages.tblr typstPackages.algo
    typstPackages.algorithmic typstPackages.lovelace typstPackages.codly
    typstPackages.finite typstPackages.bytefield typstPackages.plotst
    typstPackages.physica typstPackages.mitex typstPackages.fletcher
    typstPackages.pinit typstPackages.tasteful-pairings typstPackages.touying
    typstPackages.polylux typstPackages.diatypst typstPackages.grape-suite
    typstPackages.modern-cv typstPackages.clickworthy-resume typstPackages.brilliant-cv
    typstPackages.tablex typstPackages.showybox typstPackages.chicv
    typstPackages.academicv typstPackages.gviz typstPackages.tidy
    typstPackages.glossarium typstPackages.hydra typstPackages.typslides
    typstPackages.presentate typstPackages.minideck typstPackages.lineal
    typstPackages.leonux typstPackages.slydst typstPackages.gloat
    typstPackages.neat-cv typstPackages.toy-cv typstPackages.kiresume
    typstPackages.light-cv typstPackages.pesha typstPackages.imprecv
    typstPackages.porygon typstPackages.swe-cv typstPackages.chuli-cv
    typstPackages.mahou-cv typstPackages.equate typstPackages.ouset
    typstPackages.natrix typstPackages.ezchem typstPackages.eqalc
    typstPackages.scribe typstPackages.m-jaxon typstPackages.tinyset
    typstPackages.mannot typstPackages.ergo typstPackages.zebraw
    typstPackages.idwtet typstPackages.nassi typstPackages.wavy
    typstPackages.zap typstPackages.quill typstPackages.km
    typstPackages.atomic typstPackages.booktabs typstPackages.tablem
    typstPackages.pillar typstPackages.tabut typstPackages.tada
    typstPackages.spreet typstPackages.truthfy

    # ── Fonts ──
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];


  # ── Shell & UI Integration ────────────────────────────────────
  programs.atuin.enable = true; # Fuzzy history
  programs.zellij.enable = true; # Multiplexer
  programs.yazi.enable = true; # File manager
  fonts.fontconfig.enable = true;

  xdg.configFile = {
    "fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
    "fastfetch/logo.txt".source = ./fastfetch/logo.txt;
    "fastfetch/ghost.png".source = ../../images/ghost.png;
    "mimeapps.list".force = true;
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

  # ── Environment & Session ──────────────────────────────────────
  home.sessionVariables = {
    # ── Persistent Shader Caches ──
    DXVK_STATE_CACHE_PATH = "$HOME/.cache/dxvk";
    MESA_SHADER_CACHE_DIR = "$HOME/.cache/mesa_shaders";
    __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/nvidia-shaders";
    VKD3D_SHADER_CACHE_PATH = "$HOME/.cache/vkd3d-proton";

    # ── Developer Polish ──
    CARGO_TARGET_DIR = "$HOME/.cargo/targets";
  };

  programs.home-manager.enable = true;

  home.activation.linkLmStudioModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.cache/lm-studio
    ln -sfn ~/models ~/.cache/lm-studio/models
  '';
}
