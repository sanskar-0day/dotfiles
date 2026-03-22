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
    "tcp_bbr" # Required for BBR sysctl
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
    # ── Increase TCP buffer sizes for higher speeds ─────────────
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";

    # ── TCP fast open ───────────────────────────────────────────
    "net.ipv4.tcp_fastopen" = 3;


  };

  # systemd-resolved for better DNS handling (required for WARP)
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic"; # encrypts DNS queries
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1#cloudflare-dns.com"
      "9.9.9.9#dns.quad9.net"
      "8.8.4.4#dns.google"
    ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  # ── Firewall ───────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    # Allow local traffic and specific services
    allowPing = true;

    # KDE Connect ports (for phone ↔ desktop sync)
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];

    # WARP / VPN Compatibility (allows reverse path traffic)
    checkReversePath = "loose";
    logReversePathDrops = false;
  };

  # Shader Cache Persistence
  # These ensure shader caches are created and owned by the user on boot,
  # preventing first-launch stutters in games and AI apps.
  systemd.tmpfiles.rules = [
    "d /home/sanskar/.cache/dxvk           0755 sanskar users -"
    "d /home/sanskar/.cache/mesa_shaders   0755 sanskar users -"
    "d /home/sanskar/.cache/nvidia-shaders 0755 sanskar users -"
    "d /home/sanskar/.cache/vkd3d-proton   0755 sanskar users -"
  ];

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

  # ── System Maintenance ─────────────────────────────────────────
  # ── Logging & Auditing ─────────────────────────────────────────
  # Journald: cap log size, keep logs useful but bounded
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=256M
    MaxFileSec=1month
    MaxRetentionSec=3month
  '';

  # Coredumps: Keep small backtraces, not multi‑GB dumps
  systemd.coredump.extraConfig = ''
    Storage=journal
    ProcessSizeMax=500M
    Compress=yes
    MaxUse=1G
  '';

  # ── Services ───────────────────────────────────────────────────
  services.openssh.enable = false;
  services.flatpak.enable = true;
  services.cloudflare-warp.enable = true;
  services.avahi.enable = false;
  services.printing.enable = false;
  services.geoclue2.enable = false;
  services.packagekit.enable = false;
  systemd.services.ModemManager.enable = false; # Speeds up boot significantly
  services.fstrim.enable = true; # Trim SSD regularly
  services.irqbalance.enable = true;

  # Bluetooth Configuration (centralized)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # Save battery, only power on if toggled
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
        AutoEnable = "false"; # Don't power on adapter automatically
        ReconnectAttempts = 15;
        ReconnectInterval = 1;
      };
    };
  };
  services.blueman.enable = false;

  # Power Management (using power-profiles-daemon)
  services.power-profiles-daemon.enable = true;


  # ── Backups ────────────────────────────────────────────────────
  # Borg Backup: Daily snapshots of critical data
  # services.borgbackup.jobs."home-backup" = {
  #   paths = [ "/home/sanskar/dotfiles" "/home/sanskar/projects" "/home/sanskar/models" ];
  #   repo = "ssh://user@server:22/~/borg-repos/sanskar";
  #   encryption = {
  #     mode = "repokey-blake2";
  #     passCommand = "cat /etc/nixos/secret-borg-passphrase";
  #   };
  #   compression = "zstd,6";
  #   prune.keep = {
  #     within = "7d";
  #     daily  = 7;
  #     weekly = 4;
  #     monthly = 6;
  #   };
  # };

  # Touchpad Settings
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true;
  services.libinput.touchpad.naturalScrolling = true;

  # Kanata: Advanced Keyboard Remapper (Caps → Esc/Ctrl)
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
    delay = 0; # Was 4000000 (4 seconds!) — unnecessary on a personal machine
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
      "corectrl"
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
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "slight"; # "slight" preserves shape better than "full"
      autohint = false; # use font's own hinting instructions
    };
    subpixel = {
      rgba = "rgb"; # set to "bgr" if colors look off on your specific panel
      lcdfilter = "default";
    };
    defaultFonts = {
      sansSerif = [
        "Inter"
        "Noto Sans"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "FiraCode Nerd Font"
      ];
      serif = [ "Libertinus Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

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

  # ── Hardware & Performance ─────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;

  # Automatic process re-nicing for desktop responsiveness (Ananicy-cpp)
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      cgroup_realtime_workaround = true; # Required for NixOS cgroups v2
    };
  };

  # Advanced I/O Scheduling
  services.udev.extraRules = ''
    # NVMe: no-op scheduler (drive handles queuing internally)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"

    # SATA SSD (if any): use BFQ for better interactive responsiveness
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
  '';

  # ── Swap & Performance ────────────────────────────────────────
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Faster and better compression than lzo
    memoryPercent = 50; # Allow up to 50% of RAM to be compressed (great for AI)
  };

  # Prevent full system lockups when Games or LM Studio use too much memory
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5; # Kill heaviest process if free RAM drops below 5%
    freeSwapThreshold = 10;
    extraArgs = [
      "-g" # send SIGTERM first
      "--prefer" "'^(lmstudio|firefox|code-cursor)$'"
      "--avoid" "'^(kwin|plasmashell|kate|kanata)$'"
    ];
  };

  # Disable competing default OOM daemon
  systemd.oomd.enable = false;

  # ── Nix Settings ──────────────────────────────────────────────
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Build
      max-jobs = 4;
      cores = 4;

      # Storage & Dev
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;

      # Downloads
      max-substitution-jobs = 32;

      trusted-users = [
        "root"
        "sanskar"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      stalled-download-timeout = 10;
      connect-timeout = 5;
    };

    gc = {
      automatic = false; # Disabled in favor of nh.clean
      dates = "weekly";
      options = "--delete-older-than 14d";
      persistent = true;
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 20;
    CPUQuota = "60%";
    OOMScoreAdjust = 500;
  };

  system.stateVersion = "25.11";
}
