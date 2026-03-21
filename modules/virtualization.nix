{ config, pkgs, ... }:
{
  # ── Docker ─────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
      "log-driver" = "local"; # 100MB cap per container, auto-rotates
      "log-opts" = {
        "max-size" = "10m";
        "max-file" = "3";
      };
      "storage-driver" = "overlay2"; # already the default, but explicit is safer
      "experimental" = false;
    };
    # Socket-activated: starts on first `docker` command
    enableOnBoot = false;
  };

  # ── QEMU / KVM ────────────────────────────────────────────────
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;           # TPM emulation for Windows 11
      runAsRoot = true; # Sometimes needed for certain performance tweaks
    };
  };

  programs.virt-manager.enable = true;

  # ── Packages ───────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    distrobox
    spice-gtk          # USB redirection in VMs
    virt-viewer        # Better spice viewer
    virtio-win         # ISO with Windows VirtIO drivers
  ];
}
