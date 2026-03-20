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
  environment.sessionVariables = {
    # Fix Nvidia flickering/lag in Plasma 6
    KWIN_DRM_USE_MODIFIERS = "0";
    # Force Wayland for specific apps to avoid XWayland overhead
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # Extreme Latency/Speed Tweaks
    KWIN_X11_NO_SYNC_TO_VBLANK = "1"; # Absolute minimum input lag (may cause slight tearing)
    KWIN_TRIPLE_BUFFER = "1";         # Smoother animations on Nvidia
    # Turbo-charge startup by skipping unnecessary waits
    KDE_SESSION_UID = "1";
    PLASMA_USE_QT_SCENE_GRAPH_BACKEND = "opengl";
    # Fix slow context menus and general Qt sluggishness
    QT_LOGGING_RULES = "*.debug=false;qt.qpa.wayland=false";
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
  };

  # Bluetooth is configured centrally in hosts/nixos/default.nix
  services.blueman.enable = false;

  # Portals
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  # KDE Connect (phone ↔ desktop)
  programs.kdeconnect.enable = false;

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
