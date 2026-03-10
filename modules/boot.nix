{ config, pkgs, ... }:

{
  # ── systemd-boot ───────────────────────────────────────────────
  # Fast, simple, and reliable UEFI bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 20;
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
    # Note: tty option doesn't exist in NixOS systemd-initrd
  };

  # ── Boot Verbosity ────────────────────────────────────────────
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    # Quiet boot (safe - reduces console spam)
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=auto" # Only show status on failure
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    # Safety: Drop to shell if boot fails (kept per README)
    "boot.shell_on_fail"
  ];

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
  };

  # ── Systemd Optimizations for Faster Boot ────────────────────
  systemd.settings.Manager = {
    # Faster service startup
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    # Allow more parallel service starts
    DefaultTasksMax = "infinity";
  };

  # Optimize service startup times
  systemd.services = {
    # Make Flatpak start faster (don't wait for updates)
    flatpak-system-helper.serviceConfig = {
      TimeoutStartSec = "5s";
    };
    
    # Optimize NetworkManager to start faster
    NetworkManager.serviceConfig = {
      TimeoutStartSec = "5s";
    };
    
    # Make Bluetooth start faster (non-blocking)
    bluetooth.serviceConfig = {
      TimeoutStartSec = "5s";
    };
    
    # Optimize Cloudflare WARP to start faster
    warp-svc.serviceConfig = {
      TimeoutStartSec = "5s";
    };
    
    # Make Pipewire start faster
    pipewire.serviceConfig = {
      TimeoutStartSec = "5s";
    };
    
    # Optimize SDDM (display manager) startup
    sddm.serviceConfig = {
      TimeoutStartSec = "5s";
    };
  };
}
