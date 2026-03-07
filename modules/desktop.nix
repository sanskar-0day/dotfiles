{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Portals
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  # KDE Connect (phone ↔ desktop)
  programs.kdeconnect.enable = true;

  # ── KDE Tools ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager # Disk/partition management
    kdePackages.ark # Archive manager
    kdePackages.filelight # Disk usage visualizer
    kdePackages.gwenview # Image viewer
    kdePackages.kate # Text editor
    kdePackages.kcalc # Calculator
    kdePackages.kolourpaint # Simple image editor
  ];
}
