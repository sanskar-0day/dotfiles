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

  # ── Boot & Kernel ──────────────────────────────────────────────
  # Using the specific kernel version that worked previously
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelModules = [ "kvm" "kvm_amd" "iptables_nat" "ip_tables" ];

  # Blacklist conflicting drivers
  boot.blacklistedKernelModules = [
    "nouveau"
    "mt7921e" "mt7921_common"  # Internal MediaTek WiFi
    "rtw88_8822bu" "rtw88_8822b" "rtw_8822bu" # Default kernel driver for 8822BU
  ];

  boot.extraModprobeConfig = ''
    options ieee80211 powersave=0
    options cfg80211 ieee80211_regdom=IN
    # Push TP-Link T3U Plus (rtl88x2bu) to absolute limits
    options 88x2bu rtw_drv_log_level=1 rtw_led_ctrl=1 rtw_vht_enable=1 rtw_power_mgnt=0 rtw_enusbss=0 rtw_switch_usb_mode=1
  '';

  hardware.enableRedistributableFirmware = true;

  # WiFi external driver
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl88x2bu ];

  # ── Networking ─────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # ── Locale / Time ─────────────────────────────────────────────
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Services ───────────────────────────────────────────────────
  services.openssh.enable = false;
  services.flatpak.enable = true;
  services.cloudflare-warp.enable = true;
  services.avahi.enable = false;
  services.printing.enable = false;
  services.geoclue2.enable = false;
  services.packagekit.enable = false;
  services.fstrim.enable = true;

  # Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = false;

  # Laptop Power Management
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}="power-profile-ac.service"
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", TAG+="systemd", ENV{SYSTEMD_WANTS}="power-profile-battery.service"
  '';

  systemd.services.power-profile-ac = {
    description = "Set power profile to performance on AC";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    };
  };

  systemd.services.power-profile-battery = {
    description = "Set power profile to balanced on battery";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced";
    };
  };

  # Touchpad support
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true;
  services.libinput.touchpad.naturalScrolling = true;

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

  # Zsh must be enabled at system level for user shells to work
  # Home Manager manages the config, NixOS provides the shell
  programs.zsh.enable = true;

  # Nix Helper (Clean CLI for rebuilds)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/sanskar/dotfiles";
  };

  # Nix-LD (Run un-patched binaries, essential for AI tools/LSPs)
  programs.nix-ld.enable = false;
  services.envfs.enable = false;

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
    home-manager

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

    # Mirrors ordered by reliability and then speed
    substituters = [
      "https://cache.nixos.org"                                    # 1.1s ✓ (Most reliable)
      "https://mirrors.ustc.edu.cn/nix-channels/store"            # 1.9s ✓
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

  # ── Garbage Collection (Handled by nh) ────────────────────────
  nix.gc = {
    automatic = false;
  };

  system.stateVersion = "25.11";
}
