{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  # SDDM Wayland is much smoother in Plasma 6
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;

  # ── Plasma 6 & Nvidia Optimizations ─────────────────────────
  environment.sessionVariables = {
    # Fix Nvidia flickering/lag in Plasma 6
    KWIN_DRM_USE_MODIFIERS = "0";
    # Force Wayland for specific apps to avoid XWayland overhead
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # Smoothness tweaks
    KWIN_X11_NO_SYNC_TO_VBLANK = "0"; # Prevent tearing
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    # Reduce Plasma start-up time
    KDE_SESSION_UID = "1";
  };

  # Disable Baloo (File Indexing) - Major source of stutter and disk I/O
  systemd.user.services.baloo = {
    description = "KDE Baloo File Indexer (Disabled for performance)";
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
