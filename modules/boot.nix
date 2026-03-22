{ config, pkgs, ... }:

{
  # ── systemd-boot ───────────────────────────────────────────────
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false; # Security: Prevent kernel parameter editing at boot
      configurationLimit = 10; # Keep boot partition clean
      consoleMode = "max";
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    timeout = 0; # Set to 0 to bypass the menu entirely (hold space or shift during boot to show it)
  };

  # ── Safe & Fast Boot ──────────────────────────────────────────
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = true;
  };

  # ── Boot Verbosity ────────────────────────────────────────────
  boot.consoleLogLevel = 3; # Show warnings and errors
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=auto"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "fastboot"
    "noresume"
    "splash"
    "quiet"

    "boot.shell_on_fail"
    "nvidia-drm.modeset=1" # Required for Wayland (if used) and PRIME offload
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Better suspend/resume on NVIDIA
    "mitigations=off" # Disable CPU security mitigations for ~5-10% perf gain (Safe for non-server)
    "nowatchdog" # Disable hardware watchdog to stop periodic interrupts
    "amdgpu.dcfeaturemask=0x8" # Enable DC FP16 filter for smoother iGPU frames
    "amdgpu.ppfeaturemask=0xffffffff" # Required for GPU overclocking/undervolting
  ];

  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-6" "-T0" ]; # was -19; -6 is 10x faster to build, same decompression speed

  # ── Boot Splash (Plymouth) ───────────────────────────────────
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  # ── Kernel Hardening & Performance ──────────────────────────
  boot.kernel.sysctl = {
    # Net: Faster TCP throughput (BBR)
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Disk: SSD + RAM responsiveness
    "vm.swappiness" = 10; # Prefer RAM over swap
    "vm.dirty_ratio" = 10; # Flush dirty pages earlier to SSD
    "vm.dirty_background_ratio" = 5;
    "vm.vfs_cache_pressure" = 50; # Keep file indexes in RAM longer
    "kernel.nmi_watchdog" = 0; # Disable non-maskable interrupt watchdog
    "kernel.unprivileged_userns_clone" = 1; # Required for Rootless containers
  };

  # ── Hardware & Services ──────────────────────────────────────
  # Enable EarlyOOM to prevent system-wide lockups during heavy RAM usage
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # Kill heaviest process when RAM < 5%
    freeSwapThreshold = 10;
  };


  # Logind: Opinionated suspend/idle behavior
  services.logind = {
    settings.Login = {
      HandlePowerKey = "poweroff";
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandleSuspendKey = "suspend";
      HandleSuspendKeyLongPress = "ignore";
      HandleHibernateKey = "ignore";
      IdleAction = "ignore";
      IdleActionSec = "30min";
      AllowSuspend = "yes";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowIdle = "yes";
    };
  };

  # ── Systemd Optimizations ────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "5s";
    DefaultTimeoutStopSec = "5s";
    DefaultTasksMax = "infinity";
  };

  systemd.services = {
    flatpak-system-helper.serviceConfig.TimeoutStartSec = "5s";
    NetworkManager.serviceConfig.TimeoutStartSec = "5s";
    bluetooth.serviceConfig.TimeoutStartSec = "5s";
    warp-svc.serviceConfig.TimeoutStartSec = "5s";
    pipewire.serviceConfig.TimeoutStartSec = "5s";
    sddm.serviceConfig.TimeoutStartSec = "5s";
  };
}
