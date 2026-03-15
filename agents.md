# 🤖 Agent Architecture & Constraint Guide

This document is the source of truth for AI agents interacting with this NixOS configuration. Follow the constraints below; they are based on real stability issues and deliberate performance tradeoffs.

## ⚠️ CRITICAL CONSTRAINTS

1. **Bootloader Integrity (`modules/boot.nix`)**: This system uses a minimal `systemd-boot` setup. **Do NOT** install GRUB or Plymouth. The system previously suffered boot hangs due to initrd conflicts.
   - Current state: `timeout = 1`, `systemd.initrd = true`, `consoleLogLevel = 0`, no Plymouth.
2. **NVIDIA Driver Hot-Swapping**: Do **not** run `nixos-rebuild switch` for kernel/driver changes. Always use `nrb` (boot) and reboot.
3. **Hardware Regeneration**: `hosts/nixos/hardware.nix` includes `noatime` mount options. Preserve them if regenerating hardware config.
4. **Display Server**: KDE Plasma 6 runs on **X11** via SDDM; Wayland is disabled for NVIDIA stability.

---

## 🏗️ Flake Architecture

- **Dual Channels**: `nixos-25.11` → `pkgs`, `nixos-unstable` → `unstable`.
- **Injection**: `unstable` is passed via `specialArg` (NixOS) and `extraSpecialArg` (Home Manager).
- **Kernel Pinning**: `linuxPackages_6_12` is pinned for NVIDIA stability.

## 🎮 Gaming Subsystem (`modules/gaming.nix`)

- Wine Staging + Winetricks + Lutris/Bottles/Heroic.
- GameMode enabled with GPU optimizations accepted.
- Steam enabled with Remote Play/Dedicated Server firewall rules.
- Gamescope session enabled (use only if stable).
- FitGirl fixes: very high `vm.max_map_count` and unlimited stack.

**Note**: The Wine auto-prefix runner was removed with the repo `scripts/` cleanup.

## 💻 Shell & Editor Design

### Zsh
- System enables Zsh; Home Manager manages config.
- `home/sanskar/zshrc` is the canonical file; HM reads it.
- Keep `jq` + `fzf` in the environment for `ns`/`nu` functions.

### Neovim
- Do **not** use `programs.neovim.plugins` in Nix.
- LazyVim requires writable plugin state under `~/.local/share/nvim`.
- Nix only provides binaries via `programs.neovim.extraPackages`.

## 🌐 Networking & Nix Settings

- NetworkManager wait-online is disabled for faster boot.
- Substituters include NixOS + USTC/Tsinghua/SJTU mirrors.
- `stalled-download-timeout = 5` and `connect-timeout = 5`.
- Build limits: `max-jobs = 4`, `cores = 4`.

## 🔧 System Defaults & Trims

- `power-profiles-daemon` enabled; `auto-cpufreq` disabled.
- Disabled services: OpenSSH, Flatpak, WARP, Avahi, printing, geoclue, PackageKit, ModemManager.
- Bluetooth core enabled; `blueman` disabled to reduce autostart overhead.

