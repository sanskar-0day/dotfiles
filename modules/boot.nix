{ config, pkgs, ... }:

{
  # ── systemd-boot ───────────────────────────────────────────────
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 20;
      consoleMode = "max";
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    timeout = 1;
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
    "nowatchdog"         # Disable hardware watchdog IRQ — small but consistent win
    "mitigations=off"    # OPTIONAL: removes Spectre/Meltdown mitigations (~10% perf boost)
    # Bluetooth: disable autosuspend (fixes laptop connection lag/drops)
    "btusb.enable_autosuspend=n"
    # Ensure amdgpu and nvidia don't fight over framebuffers
    "video=efifb:off" 
    "boot.shell_on_fail"

    # ── AMD iGPU (KWin runs here) ──────────────────────────────
    "amdgpu.ppfeaturemask=0xffffffff" # unlock all power/perf features
    "amdgpu.dcfeaturemask=0x8"        # enable DC FP16 filter (smoother compositing)
    "amdgpu.freesync_video=1"         # smoother frame pacing on display output
  ];

  boot.initrd.compressor = "zstd";
  boot.initrd.compressorFlags = [ "-19" "-T0" ]; # max ratio, parallel threads

  # ── Sleep / Lid Behavior ──────────────────────────────────────
  # Using standard logind settings
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleSuspendKey = "suspend";
    HandleSuspendKeyLongPress = "ignore";
    HandleHibernateKey = "ignore";
    IdleAction = "suspend";
    IdleActionSec = "30min";
    LidSwitchIgnoreInhibited = true;
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowIdle = "yes";
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
