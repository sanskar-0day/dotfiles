{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  # SDDM Wayland can be unstable on Nvidia
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    khelpcenter                # Offline help center
    elisa                      # Media player (you have VLC)
    discover                   # Package manager GUI (you use Nix)
    drkonqi                    # Crash reporter
    oxygen                     # Old theme (you use Breeze)
  ];

  # ── Plasma 6 & Nvidia Optimizations ─────────────────────────
  environment.sessionVariables = {
    # ── NVIDIA/KWin X11 fixes (these are real and valid) ──
    KWIN_DRM_USE_MODIFIERS = "0";          # Prevents NVIDIA modifier conflicts
    KWIN_TRIPLE_BUFFER = "1";              # Required: KWin can't auto-detect NVIDIA triple buffer
    KWIN_X11_NO_SYNC_TO_VBLANK = "1";     # Reduce compositing latency
    KWIN_X11_FORCE_SOFTWARE_VSYNC = "1";  # REQUIRED pair for NO_SYNC_TO_VBLANK, prevents unbounded render loop

    # ── Suppress Qt debug noise (valid) ──
    QT_LOGGING_RULES = "*.debug=false;qt.qpa.wayland=false";

    # ── DO NOT add NIXOS_OZONE_WL, MOZ_ENABLE_WAYLAND,    ──
    # ── GDK_BACKEND=wayland, QT_QPA_PLATFORM=wayland here ──
    # ── You are on X11 — Wayland vars BREAK apps          ──
  };

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

  # ── KDE Tools ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Custom script to quickly apply performance tweaks to KDE
    (pkgs.writeShellScriptBin "plasma-fast-boot" ''
      echo "Applying ULTIMATE Plasma 6 Performance Tweaks..."
      
      # 1. Disable Splash Screen (Instant Login)
      kwriteconfig6 --file ksplashrc --group "KSplash" --key "Theme" "None"
      kwriteconfig6 --file ksplashrc --group "KSplash" --key "Engine" "none"
      
      # 2. Set Session to Start Empty (Instant Taskbar)
      kwriteconfig6 --file ksmserverrc --group "General" --key "loginMode" "emptySession"
      
      # 3. Animations: Super Fast (0.2)
      kwriteconfig6 --file kdeglobals --group "KDE" --key "AnimationDurationFactor" 0.2
      
      # 4. Disable Heavy Desktop Effects (Blur and Contrast are the heaviest)
      kwriteconfig6 --file kwinrc --group "Plugins" --key "blurEnabled" false
      kwriteconfig6 --file kwinrc --group "Plugins" --key "contrastEnabled" false
      kwriteconfig6 --file kwinrc --group "Plugins" --key "translucencyEnabled" false
      
      # 5. Disable Background Services
      kwriteconfig6 --file akonadi-firstrunrc --group "General" --key "AkonadiEnabled" false
      
      # 6. Optimize KWin for Speed
      kwriteconfig6 --file kwinrc --group "Compositing" --key "LatencyPolicy" "Low"
      kwriteconfig6 --file kwinrc --group "Compositing" --key "GLPlatformInterface" "glx"
      
      echo "Done! Restarting KWin/Plasma is recommended (or just log out and in)."
    '')

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
