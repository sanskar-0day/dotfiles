{ config, pkgs, unstable, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/nvidia.nix
    ../../modules/desktop.nix
    ../../modules/virtualization.nix
    ../../modules/gaming.nix
    ../../modules/ai.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.2.26"
  ];

  # ── Boot & Kernel ──────────────────────────────────────────────
  # Bootloader (GRUB + Sekiro theme) is configured in modules/boot.nix
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelModules = [ "kvm" "kvm_amd" "iptables_nat" "ip_tables" ];

  # Blacklist conflicting drivers
  boot.blacklistedKernelModules = [
    "nouveau"
    "mt7921e" "mt7921_common"
    "rtw88_8822bu" "rtw88_8822b"
  ];

  boot.extraModprobeConfig = ''
    options ieee80211 powersave=0
    options cfg80211 ieee80211_regdom=IN
  '';

  hardware.enableRedistributableFirmware = true;

  # WiFi external driver
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl88x2bu ];

  # ── Networking ─────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # ── Locale / Time ─────────────────────────────────────────────
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Services ───────────────────────────────────────────────────
  services.openssh.enable = true;
  services.flatpak.enable = true;
  services.cloudflare-warp.enable = true;

  # Kanata – always-active keyboard remapper
  services.kanata = {
    enable = true;
    keyboards.default = {
      config = builtins.readFile ./kanata.kbd;
      extraDefCfg = "process-unmapped-keys yes";
      devices = [];   # empty = capture all keyboards
    };
  };

  # Steam is configured in modules/gaming.nix

  # Zsh (required for it to work as login shell)
  programs.zsh.enable = true;

  # ── User ───────────────────────────────────────────────────────
  users.users.sanskar = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel" "networkmanager" "docker" "kvm" "libvirtd"
      "video" "audio" "input" "storage" "optical"
      "dialout" "lp" "bluetooth" "render"
    ];
  };

  # ── System Packages ────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Core tools
    vim wget git neovim gcc gnumake
    pciutils usbutils

    # Services
    kanata cloudflare-warp

    # AI Coding Tools (global from unstable)
    unstable.codex
    unstable.gemini-cli
    unstable.qwen-code
    unstable.opencode
  ];

  # ── Swap & Performance ────────────────────────────────────────
  zramSwap.enable = true;

  # ── Nix Settings ──────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Build — uses ~half of 16 cores / 22GB RAM
    max-jobs = 4;
    cores = 4;

    # Downloads
    max-substitution-jobs = 8;
    http-connections = 8;
    auto-optimise-store = true;

    # Mirrors ordered by speed (tested from your connection)
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"            # 1.9s ✓
      "https://cache.nixos.org"                                    # 1.1s ✓
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"   # 2.1s ✓
      "https://mirror.sjtu.edu.cn/nix-channels/store"             # 3.8s ✓
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    # Auto-skip stalled downloads
    stalled-download-timeout = 5;
    connect-timeout = 5;
  };

  # ── Garbage Collection (every 15 days) ────────────────────────
  nix.gc = {
    automatic = true;
    dates = "*-*-1,15 03:00:00";  # 1st and 15th of each month at 3am
    options = "--delete-older-than 15d";
  };

  system.stateVersion = "25.11";
}