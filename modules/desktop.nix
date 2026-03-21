{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  # SDDM Wayland can be unstable on Nvidia
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;

  # ── Plasma 6 & Nvidia Optimizations ─────────────────────────
  # ── Environment Variables ──────────────────────────────────────
  # Opinionated X11-only vars for NVIDIA stability.
  # CRITICAL: We DO NOT add MOZ_ENABLE_WAYLAND or OZONE_WL here.
  environment.sessionVariables = {
    # NVIDIA/KWin X11 specific fixes
    KWIN_DRM_USE_MODIFIERS = "0"; # Prevents artifacting on some NVIDIA cards
    KWIN_TRIPLE_BUFFER = "1"; # Critical for NVIDIA X11 smoothness
    KWIN_X11_NO_SYNC_TO_VBLANK = "1"; # Reduce compositing latency
    KWIN_X11_FORCE_SOFTWARE_VSYNC = "1"; # Prevents unbounded render loops with NO_SYNC

    # Suppress Qt debug noise in terminal
    QT_LOGGING_RULES = "*.debug=false;qt.qpa.wayland=false";

    # Force Electron apps to use X11 backends (prevents transparent windows)
    ELECTRON_OZONE_PLATFORM_HINT = "x11";
  };

  # ── Bloat Removal ─────────────────────────────────────────────
  # We exclude these from the default Plasma install to keep the
  # system lean and the application menu clean.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    khelpcenter # Offline help (browser is enough)
    elisa # Basic music player (VLC is better)
    discover # GUI package manager (Nix is preferred)
    drkonqi # Crash reporter
    oxygen # Legacy theme
    kate # We use Neovim/VSCode
    krdp # Remote desktop service
  ];

  # Disable Baloo (File Indexing) - Major source of stutter and disk I/O
  systemd.user.services.baloo = {
    description = "KDE Baloo File Indexer (Disabled for performance)";
    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };

  # Disable Akonadi (PIM Service) - Extremely heavy and slow startup
  # If you use KMail or KOrganizer, you may want to re-enable this.
  systemd.user.services.akonadi = {
    description = "Akonadi PIM Service (Disabled for performance)";
    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };

  # ── Audio ─────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true; # Manages Bluetooth audio profiles (essential)

    extraConfig.pipewire."99-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 64; # 1.3ms latency (default: 1024 = 21ms)
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 512;
      };
    };
  };

  # Bluetooth is configured centrally in hosts/nixos/default.nix
  services.blueman.enable = false;

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    # Force KDE portal for everything to prevent hangs
    config.common.default = "kde";
  };

  # KDE Connect (phone ↔ desktop)
  programs.kdeconnect.enable = true;

  # AMD GPU Tuning
  programs.corectrl.enable = true;

  # ── KDE Tools ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager # Disk/partition management
    kdePackages.ark # Archive manager
    kdePackages.filelight # Disk usage visualizer
    kdePackages.gwenview # Image viewer
    kdePackages.konsole # Terminal
    kdePackages.kate # Text editor
    kdePackages.kcalc # Calculator
    kdePackages.kolourpaint # Simple image editor
  ];
}
