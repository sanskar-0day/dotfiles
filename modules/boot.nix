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
    emergencyAccess = false;
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
    # Bluetooth: disable autosuspend (fixes laptop connection lag/drops)
    "btusb.enable_autosuspend=n"
    # Ensure amdgpu and nvidia don't fight over framebuffers
    "video=efifb:off" 
    "boot.shell_on_fail"
  ];

  # ── Sleep / Lid Behavior ──────────────────────────────────────
  # On AC: never suspend (lid, idle, or power button)
  # On battery: suspend on lid close, idle after 30min
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

  # AC power suspend blocker - masks suspend when plugged in
  systemd.services.ac-suspend-block = {
    description = "Block suspend while on AC power";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    script = ''
      if [ -f /sys/class/power_supply/AC/uevent ] && \
         grep -q "POWER_SUPPLY_ONLINE=1" /sys/class/power_supply/AC/uevent; then
        systemctl mask systemd-suspend.service systemd-hibernate.service
      fi
    '';
  };

  # udev rule triggers on AC plug/unplug to update suspend policy
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ACTION=="change", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}="ac-power-toggle.service"
  '';

  systemd.services.ac-power-toggle = {
    description = "Toggle suspend on AC power change";
    serviceConfig = {
      Type = "oneshot";
    };
    path = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    script = ''
      if grep -q "POWER_SUPPLY_ONLINE=1" /sys/class/power_supply/AC/uevent; then
        systemctl mask systemd-suspend.service systemd-hibernate.service
      else
        systemctl unmask systemd-suspend.service systemd-hibernate.service
      fi
    '';
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
