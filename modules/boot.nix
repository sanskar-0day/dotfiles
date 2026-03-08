{ config, pkgs, ... }:


{
  # ── systemd-boot ───────────────────────────────────────────────
  # The default NixOS systemd-bootloader. Drastically faster than GRUB.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    systemd-boot = {
      enable = true;
      editor = false;         # Disable the editor for security and speed
      configurationLimit = 10;
    };

    # 0 seconds to pick a generation — instant boot into the active OS
    timeout = 0;
  };

  # ── Plymouth Boot Splash ─────────────────────────────────────
  # Using adi1090x's premium animated themes (80+ options)
  # Change theme name to try others: rings, hexagon_dots, deus_ex, etc.
  boot.plymouth = {
    enable = true;
    theme = "hud_3";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "hud_3" ]; })
    ];
  };

  # ── Silent & Fast Boot ────────────────────────────────────────
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Replace legacy bash initrd with hyper-fast parallel Systemd initrd
  boot.initrd.systemd.enable = true;
  boot.loader.grub.enable = false;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "boot.shell_on_fail"
  ];

  # ── Faster Shutdown ───────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
