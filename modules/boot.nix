{ config, pkgs, ... }:

{
  # ── systemd-boot ───────────────────────────────────────────────
  # Fast, simple, and reliable UEFI bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 10;
      # Use maximum resolution for the console to avoid mode switches
      consoleMode = "max";
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    # Set to 0 for instant boot. Hold SPACE during boot to see the menu.
    timeout = 0;
  };

  # ── Safe & Fast Boot ──────────────────────────────────────────
  # Using systemd in initrd is faster as it parallelizes module loading.
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = true; # Safety: Allow root shell on failure
  };

  # ── Boot Verbosity ────────────────────────────────────────────
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=auto" # Only show status on failure
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "boot.shell_on_fail"         # Safety: Drop to shell if boot fails
    "nowatchdog"
    "fastboot"                   # Skip minor filesystem checks
  ];

  # ── Faster Shutdown ───────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
