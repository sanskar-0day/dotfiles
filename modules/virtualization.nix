{ config, pkgs, ... }:
{
  # ── Docker ─────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    daemon.settings.dns = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
  };

  # ── QEMU / KVM ────────────────────────────────────────────────
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;           # TPM emulation for Windows 11
    };
  };

  programs.virt-manager.enable = true;

  # ── Packages ───────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    distrobox
    spice-gtk          # USB redirection in VMs
  ];
}