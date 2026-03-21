# 🤖 Agent Architecture & Constraint Guide

This document is the source of truth for AI agents interacting with this NixOS configuration. It covers surgical optimizations, hardware constraints, and workflow patterns.

## ⚠️ CRITICAL CONSTRAINTS (DO NOT BREAK)

1.  **Display Server Integrity**:
    -   **X11 ONLY**: All KDE Plasma sessions run on X11 via SDDM. Wayland is disabled for NVIDIA driver stability.
    -   **NO Wayland Env Vars**: Never add `NIXOS_OZONE_WL`, `MOZ_ENABLE_WAYLAND`, `QT_QPA_PLATFORM=wayland`, or `GDK_BACKEND=wayland`. These cause hangs and crashes on this NVIDIA setup.
2.  **Bootloader Safety (`modules/boot.nix`)**:
    -   Minimal `systemd-boot` with `timeout = 1`.
    -   **NO Plymouth**: Previously caused initrd hangs.
    -   **pinned Kernel**: Uses `linuxPackages_6_12` for production NVIDIA stability.
3.  **Kernel/Driver Deployment**:
    -   Always use `nrb` (boot/reboot) for kernel or NVIDIA driver changes. Never use `switch`.

---

## 🏗️ System Architecture

### 🚀 Responsiveness Stack
- **ananicy-cpp**: Auto-renicing (rules in `ananicy-cpp` package).
- **earlyoom**: Thresholds set at 5% RAM / 10% Swap to prevent lockups.
- **nix-daemon**: Isolated at `idle` priority with a 60% CPU cap.

### 🌐 Networking (The `resolved` fix)
- **services.resolved**: Enabled with opportunistic DNSoverTLS.
- **NO networking.nameservers**: Conflicts with resolved's loopback listener.
- **TCP BBR**: requires `tcp_bbr` in `boot.kernelModules` and `fq` qdisc.

### 🎮 Graphics & Gaming
- **AMD iGPU**: DC FP16 filter (`amdgpu.dcfeaturemask=0x8`) for smoother Plasma frames.
- **NVIDIA Prime**: Production branch (`550.x` or similar) with offload scripts.
- **Vulkan Infrastructure**: Full loader and validation layers for both AMD and NVIDIA.
- **Shader Caches**: Persistent directories in `~/.cache` via `tmpfiles.rules`.

### 🛠️ Developer Workflow
- **devShells**: Specialized toolchains live in `flake.nix` (e.g., `ds`, `web`).
- **Global Trim**: Keep `home.packages` limited to cross-project utilities.
- **Automated QA**: `nix flake check` builds the system closures to verify syntax/logic.

---

## 🔧 Maintenance Notes

- **Logs**: Journald capped at 1GB; Coredumps capped at 1GB (Storage=journal).
- **Disk**: NVMe uses `none` scheduler; SATA SSDs use `bfq`.
- **Power**: AC/Battery switching handled via `power-profile-ac.service` triggered by udev tags.

## ⌨️ Kanata Keyboard Design
Tap/Hold behaviors are sensitive. Timing is 200/200. Home-row mods are the primary efficiency gain.
