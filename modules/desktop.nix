{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;

  # ── Plasma 6 Optimizations ───────────────────────────────────
  # Disable the splash screen for near-instant desktop entry
  environment.sessionVariables = {
    # Fix Nvidia flickering/lag in Plasma 6 (artifacting)
    KWIN_DRM_USE_MODIFIERS = "0";
    # Force Plasma to use high-performance rendering paths
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    # Fix KDE Startup Lag (Wait less for some services)
    KDE_SESSION_UID = "1";
  };

  # Audio ─────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true; # Manages Bluetooth audio profiles (essential)
  };

  # Bluetooth (hardened + more robust)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Extra BlueZ settings → /etc/bluetooth/main.conf
    settings = {
      General = {
        # Enable experimental features (often needed for modern earbuds/codecs)
        Experimental = true;
        # Make device discoverable/connectable quickly without long delays
        FastConnectable = true;
        # Improve compatibility with headsets and modern controllers
        ControllerMode = "dual";
        Enable = "Source,Sink,Media,Socket";
        # Stronger privacy & encryption defaults
        Privacy = "network";
        JustWorksRepairing = "never";
        MinEncryptionKeySize = 16;
      };
      Policy = {
        # Ensure the adapter is automatically enabled on boot
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = false;

  # Portals
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  # KDE Connect (phone ↔ desktop)
  programs.kdeconnect.enable = false;


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
