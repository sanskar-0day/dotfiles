{
  config,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/nvidia.nix
    ../../modules/desktop.nix
    ../../modules/virtualization.nix
    ../../modules/gaming.nix
    ../../modules/ai.nix
    ../../modules/typst.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # ── Boot & Kernel ──────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelModules = [
    "kvm"
    "kvm_amd"
    "iptables_nat"
    "ip_tables"
  ];

  boot.blacklistedKernelModules = [
    "nouveau"
    "mt7921e"
    "mt7921_common"
  ];

  boot.extraModprobeConfig = ''
    options ieee80211 powersave=0
    options cfg80211 ieee80211_regdom=IN
    # TP-Link T3U Plus (rtl88x2bu) - Stable high-perf settings
    options 88x2bu rtw_drv_log_level=0 rtw_led_ctrl=1 rtw_vht_enable=1 rtw_power_mgnt=0 rtw_enusbss=0 rtw_switch_usb_mode=1
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl88x2bu ];

  # ── Networking ─────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  # TCP Stack Optimizations (Gaming & Latency)
  boot.kernel.sysctl = {
    # Increase TCP buffer sizes for higher speeds
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    
    # TCP fast open
    "net.ipv4.tcp_fastopen" = 3;
    
    # BBR Congestion Control (Google's algo for better throughput on lossy networks)
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  
  # systemd-resolved for better DNS handling (required for WARP)
  services.resolved = {
    enable = true;
    fallbackDns = [ "8.8.4.4" "9.9.9.9" ];
    domains = [ "~." ];
  };

  # Global DNS nameservers
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" ];

  systemd.services.NetworkManager-wait-online.enable = false;

  # ── Firewall ───────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    # Allow local traffic and specific services
    allowPing = true;
    
    # KDE Connect
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    
    # WARP / VPN Compatibility
    checkReversePath = "loose";
    logReversePathDrops = false;
  };

  # ── Locale / Time ─────────────────────────────────────────────
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # ── Services ───────────────────────────────────────────────────
  services.openssh.enable = false;
  services.flatpak.enable = true;
  services.cloudflare-warp.enable = true;
  services.avahi.enable = false;
  services.printing.enable = false;
  services.geoclue2.enable = false;
  services.packagekit.enable = false;
  services.fstrim.enable = true;
  services.irqbalance.enable = true;

  # Bluetooth (centralized)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
        ControllerMode = "dual";
        Enable = "Source,Sink,Media,Socket";
        # Consumer earbuds usually need lower security settings to connect reliably
        Privacy = "off";
        JustWorksRepairing = "always";
        MinEncryptionKeySize = 7;
        ExperimentalBatteryReporting = true;
        # Support multiple profiles (A2DP & HFP) simultaneously
        MultiProfile = "multiple";
        # Faster discovery and reconnection
        AutoConnectTimeout = 60;
      };
      # Better support for modern Bluetooth mice and game controllers
      Input = {
        UserspaceHID = true;
      };
      # Reconnect automatically
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 15;
        ReconnectInterval = 1;
      };
    };
  };
  services.blueman.enable = false;

  # Power Management
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

  # Touchpad
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true;
  services.libinput.touchpad.naturalScrolling = true;

  # Kanata – keyboard remapper
  services.kanata = {
    enable = true;
    keyboards.default = {
      config = builtins.readFile ./kanata.kbd;
      extraDefCfg = "process-unmapped-keys yes";
      devices = [ ];
    };
  };

  programs.zsh.enable = true;

  # Nix Helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/sanskar/dotfiles";
  };

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  # ── Security ───────────────────────────────────────────────────
  security.sudo.enable = true;
  security.doas = {
    enable = true;
    extraRules = [
      {
        users = [ "sanskar" ];
        keepEnv = true;
        persist = true;
      }
    ];
  };
  # Alias sudo → doas if preferred, but keep both for compatibility
  environment.shellAliases.sudo = "doas";

  security.pam.services.login.failDelay = {
    enable = true;
    delay = 4000000; # 4 seconds
  };

  # ── User ───────────────────────────────────────────────────────
  users.users.sanskar = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "kvm"
      "libvirtd"
      "video"
      "audio"
      "input"
      "storage"
      "optical"
      "dialout"
      "lp"
      "bluetooth"
      "render"
    ];
  };

  # ── System Packages ────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Core tools
    vim
    wget
    git
    neovim
    gcc
    gnumake
    pciutils
    usbutils
    iw
    ethtool
    util-linux

    # Services
    kanata
    cloudflare-warp
    home-manager

    # AI Coding Tools (from unstable)
    unstable.lmstudio
    unstable.codex
    unstable.gemini-cli
    unstable.qwen-code
    unstable.opencode
  ];

  # ── Fonts ──────────────────────────────────────────────────────
  # Commonly used fonts for Typst, development, and general use
  fonts.packages = with pkgs; [
    # Monospace / Code fonts
    jetbrains-mono
    fira-code
    fira-mono
    hack-font
    victor-mono
    iosevka
    commit-mono
    cascadia-code

    # Serif fonts (Typst defaults)
    libertinus
    stix-two

    # Sans-serif fonts
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts
    ubuntu-classic
    cantarell-fonts

    # Typst / PDF rendering
    corefonts
  ];

  # ── XDG ────────────────────────────────────────────────────────
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # ── Swap & Performance ────────────────────────────────────────
  zramSwap = {
    enable = true;
    memoryPercent = 50; # Allow up to 50% of RAM to be compressed (great for AI)
  };

  # Prevent full system lockups when Games or LM Studio use too much memory
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5; # Kill heaviest process if free RAM drops below 5%
  };

  # ── Nix Settings ──────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Build
    max-jobs = "auto";
    cores = 0;

    # Downloads
    max-substitution-jobs = 32;
    http-connections = 64;
    auto-optimise-store = true;
    
    trusted-users = [ "root" "sanskar" ];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    stalled-download-timeout = 10;
    connect-timeout = 5;
  };

  nix.gc = {
    automatic = false;
  };

  system.stateVersion = "25.11";
}
