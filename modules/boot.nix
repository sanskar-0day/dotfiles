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
    "nowatchdog"        # Skip hardware watchdog timer probing
  ];

  # ── Faster Shutdown ───────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
