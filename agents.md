# 🤖 Agent's Architecture Guide

This document is a technical deep-dive for AI agents (like Antigravity) outlining the inner workings, dependencies, logic, and edge-case mitigations implemented across this NixOS configuration.

> **CRITICAL RULE FOR ALL AGENTS**: If you modify *anything* related to theming, gaming memory allocations, home-manager bindings, or bootloader sequences, you **MUST** consult this document first. Overriding existing logic without understanding the interconnected parts will severely break the user's system.

## 🏗️ Core Architecture (Flake Level)

### 1. `flake.nix` (The Entry Point)
- **Inputs**: Pulls `nixpkgs` (NixOS 25.11 stable), `nixpkgs-unstable` (for bleeding-edge developer tools and AI models), `home-manager` (mapped to stable), and `stylix` (system-wide theming).
- **SpecialArgs**: Injects `unstable` and `inputs` globally into all NixOS modules (`hosts/nixos/default.nix`) and extraSpecialArgs into `home-manager` modules.
  - *Agent Action*: To install a bleeding-edge package anywhere in the codebase, simply reference `unstable.packageName`.
- **Mitigation - Home Manager Clobbering**: `home-manager.backupFileExtension = "bak"` is set. If the system detects a file collision during rebuild (like `~/.gtkrc-2.0` existing before Nix tries to place it), it automatically renames the existing file to `.bak` instead of failing the entire switch operation.
- **Architectural Flow**: `nixosConfigurations.nixos` calls `./hosts/nixos/default.nix`, attaches the `stylix` NixOS Module, attaches the `home-manager` NixOS module, and directly points HM's user space configurations at `./home/sanskar/default.nix`.

## 🌐 Network Stability & Build Strategy (`hosts/nixos/default.nix`)

The ISP in this region notoriously blocks or severely throttles `cache.nixos.org`. 
If you simply run `nixos-rebuild`, it will hang forever.

### Nix Settings Hardening
- **Substituters**: Explicitly ordered array of mirrors prioritising speed. `mirrors.ustc.edu.cn` (1.9s latency) sits at the top, followed by `cache.nixos.org` (1.1s latency - but prone to connection resets), then TUNA, then SJTUG.
- **Cache Forcing**: `trusted-public-keys` specifically allows the official key so third-party mirrors can serve official signed substitutes.
- **Agresive Timeouts**: `stalled-download-timeout` and `connect-timeout` are hardcoded to `5` seconds. If a TCP stream drops below 1 byte/sec for 5 seconds, Nix aborts that mirror and cycles down the substituter list instantly.
- **Resource Limits**: Compiling from source (if caches fail) on a 16-core system causes an OOM kernel panic if unrestricted. `max-jobs = 4` and `cores = 4` forcefully restricts builds to use less than half the system's total processing resources.

## 🎮 The Gaming Stack (`modules/gaming.nix` & `scripts/`)

Gaming on Linux is highly volatile. This setup supports Windows executables (specifically FitGirl / Oodle-based repacks) through a multi-layered approach.

### 1. Engine Initialization (`gaming.nix`)
- **Compatibility**: `hardware.graphics.enable32Bit = true;` unconditionally loads 32-bit Mesa and OpenGL drivers necessary for legacy Windows API calls.
- **Wine Platform**: Uses `wineWowPackages.stagingFull`. Staging ships experimental patches (like CSMT) that are crucial for modern AAA gaming.
- **Memory Hotfix (CRITICAL)**: FitGirl installers employ extreme Oodle multi-threaded decompression algorithms.
  - **The Problem**: Default Linux stack sizes (8MB) and `max_map_count` (65530) instantly trigger a `Stack Overflow` exception in Wine (`Unhandled exception: stack overflow inside wine-10.20-staging`).
  - **The Solution**: The kernel `vm.max_map_count` is forcibly raised to `2147483642`. User `security.pam.loginLimits` are elevated to allow `item = "stack"; value = "unlimited"`.

### 2. Auto EXE Handler Logic (`home/sanskar/default.nix` & `scripts/wine-run.sh`)
- **The Wrapper**: `scripts/wine-run.sh` wraps the `wine` binary. It parses the parent folder of the `.exe`, and provisions a totally isolated Wine prefix (`$HOME/Games/wine-<foldername>`).
- **Dependency Bootstrap**: If it detects the prefix is empty, it runs an unattended `winetricks -q vcrun2022 dxvk d3dcompiler_47 corefonts`. This guarantees Vulcan translation and Microsoft runtimes are injected before the game UI even loads. It executes `ulimit -s unlimited` immediately prior to `wine setup.exe`.
- **MIME Hijacking**: `default.nix` invokes `xdg.desktopEntries` and `xdg.mimeApps` to map the custom wrapper script to `application/x-ms-dos-executable` and `application/x-msdownload`. 
- **The Result**: A user can blindly double-click any `setup.exe` in KDE Dolphin, and all the Linux-side complexity abstraction handles itself.
- **Agent Action**: If Home Manager ever throws `Existing file '/home/sanskar/.config/mimeapps.list' would be clobbered`, understand that `.bak` mapping failed because a previous `.bak` already exists. The system relies on `xdg.configFile."mimeapps.list".force = true;` to overwrite it ruthlessly.

## 🎨 Design Systems (`modules/stylix.nix` & `modules/boot.nix`)

There are deliberate overlapping design systems that an Agent must navigate carefully.

### 1. Stylix (The UI Dominator)
- **Base16**: Driven entirely by a single wallpaper (`../images/romantic-night-sky`) mapped to the `Dracula` base16 YAML scheme.
- **Reach**: Stylix forces KDE Plasma (Global Theme, Colors, Window Decorations), GTK3/GTK4, Alacritty/Kitty, Neovim, and all CLI utilities (`bat`, `btop`, `fzf`, `lazygit`, Starship) to conform instantly.
- **Agent Action**: NEVER manually configure `config.theme` or `color_theme` inside variables for supporting tools (e.g. `programs.btop.settings.color_theme` in `home/tools.nix`). If you do so without invoking `lib.mkDefault`, you will trigger a Nix evaluation conflict. Let Stylix manage the variables organically.

### 2. Boot Sequence Exclusion Zone
- **The Conflict**: Stylix attempts to theme the bootloader by default.
- **The Override**: `stylix.targets.plymouth.enable = false;` and `stylix.targets.grub.enable = false;` actively reject the Stylix bootloader logic.
- **The Reality**: The user relies heavily on a 1080p Sekiro Anime derivation (`sekiroGrubTheme` defined in `boot.nix`). The Plymouth splash screen uses `boot.plymouth.theme = "lone"` relying directly on the `adi1090x-plymouth-themes` package override mapped against the `lone` loader. 

## 🛡️ Operational Workflows (`home/sanskar/shell.nix`)

> **WARNING**: Never advise the user to run `sudo nixos-rebuild switch`.

### `nrs` vs `nrs-live` Context
NVIDIA drivers completely crash X11/Wayland sessions during kernel module hot-reloads (which `.target` reactivation hooks trigger during a `switch`). 
- **`nrs`**: Bound to `sudo nixos-rebuild boot`. Installs the configuration to `/run/current-system/` safely, skipping the systemd reload. The user must manually reboot, but their live display is protected.
- **`nrs-live`**: Bound to the original `switch`. Included strictly for testing non-graphics changes or when a display failure is acceptable. 
- *Both commands automatically append `--fallback` to guarantee execution if the USTC cache drops packets midway.*

### Hybrid Neovim Ecosystem (`nvim.nix` vs `lua/`)
The system does not manage Neovim plugins via `nixpkgs`. It manages binary LSPs, formatters, and compilers via `extraPackages` mapped directly against the Neovim derivation path. 
`xdg.configFile."nvim/lua/"` symlinks user-space Lua files out of standard Nix read-only store isolation.
This allows the plugin manager (`lazy.nvim`) to load locally, providing lightning-fast startup cache mechanisms (`~/.local/share/nvim/lazy/`), while letting Nix provide unbreakable syntax trees (e.g. `pkgs.tree-sitter`).
