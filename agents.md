# 🤖 Agent Architecture & Constraint Guide

This document is the absolute source of truth for AI agents interacting with this NixOS configuration. It outlines the complex interplay between different configuration modules, why certain architectural decisions were made, and constraints you MUST adhere to when executing tasks.

## ⚠️ CRITICAL CONSTRAINTS

1. **Bootloader Integrity (`modules/boot.nix`)**: This system utilizes a highly optimized `systemd-boot` sequence. **NEVER** attempt to install GRUB, Plymouth splash screens, or modify the bootloader to include GUI themes. The system previously suffered catastrophic boot hangs due to `systemd-initrd` conflicting with Plymouth and GRUB configurations. 
   - *Current State*: `timeout = 0`, `systemd.initrd = true`, `consoleLogLevel = 0`.
2. **NVIDIA Driver Hot-Swapping**: Do not run `sudo nixos-rebuild switch` to apply kernel or video driver changes. Changing NVIDIA states on a live Wayland session will crash the display. You must advise the user to use `nrb` (alias for `nixos-rebuild boot`) and reboot.
3. **Hardware Modifications**: The `hosts/nixos/hardware.nix` file includes performance modifications (`noatime` on `ext4` mounts). If you are asked to regenerate hardware configs, you must manually persist these `options = [ "noatime" ];` arrays.

---

## 🏗️ Flake Architecture (`flake.nix` & `hosts/nixos/default.nix`)

- **Dual-Channel Packages**: The flake imports both `nixos-25.11` (mapped to `pkgs`) and `nixos-unstable` (mapped to `unstable`). 
- **Global Injection**: `unstable` is passed as a `specialArg` to the NixOS system and `extraSpecialArg` to Home Manager. To install bleeding-edge software anywhere in the repository, simply declare `unstable.<package_name>`.
- **Kernel Pinning**: The system is explicitly pinned to `pkgs.linuxPackages_6_12` in `hosts/nixos/default.nix` to maintain stability with the `production` branch of the proprietary NVIDIA drivers defined in `modules/nvidia.nix`.

## 🎮 The Gaming Subsystem (`modules/gaming.nix` & `scripts/wine-run.sh`)

This system relies on a delicate balance of kernel parameters and wrapper scripts to play heavily compressed Windows games seamlessly.

### The FitGirl Exception
FitGirl repacks utilize the Oodle decompressor, which spawns thousands of threads and requires massive memory maps. Standard Linux security constraints will crash these installers immediately.
- **The Fix**: `modules/gaming.nix` forcefully injects `boot.kernel.sysctl."vm.max_map_count" = 2147483642;` and raises `security.pam.loginLimits` for stack allocation to `unlimited`. Do not alter these sysctl parameters, or the user will lose the ability to install games.

### Headless MIME Execution
- **Logic Flow**: In `home/sanskar/default.nix`, `xdg.mimeApps` binds `.exe` extensions to a custom `.desktop` entry named `wine-run`.
- **Execution**: The script `scripts/wine-run.sh` acts as a hypervisor. If a user double-clicks an executable, the script dynamically spawns a localized WINEPREFIX in the parent directory, auto-injects `dxvk` and `vcrun2022` via unattended `winetricks`, sets the process `ulimit -s unlimited`, and launches the binary via `wineWowPackages.stagingFull`.

## 💻 Developer & Editor Design

### Neovim Separation of Concerns (`home/sanskar/nvim.nix`)
This repository breaks standard Nix conventions regarding Neovim.
- **Rule**: NEVER attempt to install Neovim plugins using `programs.neovim.plugins = [ pkgs.vimPlugins... ]`. 
- **The Rationale**: The user relies on **LazyVim**, which requires read-write access to its own state directories (`~/.local/share/nvim/lazy`) to hot-load plugins. 
- **The Nix Role**: Nix is used strictly to provision the system-level binary dependencies required by the plugins. Compilers, LSP servers (e.g., `nil`, `ruff`, `zls`), and formatters (e.g., `black`, `stylua`) are injected via `programs.neovim.extraPackages`.
- **The Link**: The Lua configuration is mapped entirely outside the Nix store via `xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;`.

### Shell Environment (`home/sanskar/shell.nix`)
- **Fuzzy Finders**: The user has custom ZSH functions (`ns` and `nu`) that pipeline `nix search`, `jq`, and `fzf` together for instant terminal package searching. If modifying shell dependencies, ensure `jq` and `fzf` remain in the environment.
- **Multi-Account Swap**: A custom `swap-gemini` bash function allows the user to rotate OAuth credentials for the Gemini CLI by symlinking JSON profiles located in `~/.config/gemini/profiles/`.

## 🌐 Network & Build Optimization
- **Aggressive Mirrors**: The user resides in a region where standard Nix caches frequently stall. `hosts/nixos/default.nix` implements an explicit array of substituters prioritizing `ustc.edu.cn` and `tuna.tsinghua.edu.cn` over `cache.nixos.org`. 
- **Timeouts**: `stalled-download-timeout` is locked to 5 seconds to force the Nix daemon to rapidly cycle to the next mirror rather than hanging the build.
- **Resource Limits**: Local compiling is throttled to `max-jobs = 4` and `cores = 4` to prevent OOM panics on the 16-core CPU.