{ config, pkgs, unstable, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/nvidia.nix
    ../../modules/desktop.nix
    ../../modules/virtualization.nix
  ];

  nixpkgs.config.allowUnfree = true;

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
      devices = [];   # empty = capture all keyboards
    };
  };

  # ── Steam ──────────────────────────────────────────────────────
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;

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
    max-jobs = 4;
    cores = 0;
    auto-optimise-store = true;
  };

  # ── Garbage Collection (every 15 days) ────────────────────────
  nix.gc = {
    automatic = true;
    dates = "*-*-1,15 03:00:00";  # 1st and 15th of each month at 3am
    options = "--delete-older-than 15d";
  };

  system.stateVersion = "25.11";
}