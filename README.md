# Sanskar's NixOS Profile

A stability‑first NixOS configuration for a hybrid AMD + NVIDIA laptop. The focus is fast boot, predictable behavior, and reliable NVIDIA gaming. The repo uses Nix Flakes and Home Manager so system and user config rebuild cleanly from source.

## Goals
- Stability over novelty (pinned kernel + NVIDIA production driver).
- Fast boot by trimming non‑essential services.
- Reliable gaming via PRIME offload and a minimal Steam launch profile.
- Clear, safe rebuild workflows.

## Quick Start
### Bootstrap
Run `setup.sh`, then build a boot entry and reboot:
```
sudo nixos-rebuild boot --flake ~/dotfiles#nixos
```

### Safe rebuilds
- `nrb` — build boot entry (safe for NVIDIA), then reboot.
- `hms` — apply Home Manager changes.

## System Design (Plain English)
### Boot
- Uses `systemd-boot` with a 1‑second timeout.
- Plymouth is disabled to avoid initrd conflicts.
- systemd initrd is enabled for parallel module loading.

### Desktop
- KDE Plasma 6 on **X11** (Wayland disabled for NVIDIA stability).
- Baloo (indexing) and Akonadi (PIM) are disabled to reduce startup lag.
- KDE Connect is disabled.

### Power
- `power-profiles-daemon` is enabled.
- `auto-cpufreq` is disabled for stability.

### Storage
- ext4 `noatime` is preserved.
- SSD trim is enabled via `fstrim`.
- zram swap enabled.

### GPU
- NVIDIA production driver branch.
- PRIME offload configured for games.
- 32‑bit graphics support enabled for Wine/older games.

### Services trimmed for boot speed
Disabled by design:
- OpenSSH, Flatpak, Cloudflare WARP
- Avahi, Printing, Geoclue2, PackageKit, ModemManager
- Blueman GUI (Bluetooth core is still enabled)

## Steam Launch Options (Stable & Fast)
Use this as your default profile:
```
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only gamemoderun %command%
```
Tips:
- Add `mangohud` only when you need stats.
- Avoid gamescope until the base run is stable.
- For stubborn games, test: `PROTON_USE_WINED3D=1 %command%`.

## Kanata Keyboard Layout (Detailed)
Kanata runs system‑wide and uses tap/hold behavior to turn home‑row keys into modifiers.

### Core idea
- Tap a key = normal character.
- Hold a key = modifier or layer.
- Tap‑hold timing is 200ms/200ms across the config.

### Home row modifiers
Left hand:
- `A` → Super
- `S` → Alt
- `D` → Ctrl
- `F` → Shift

Right hand:
- `J` → Shift
- `K` → Ctrl
- `L` → Alt
- `;` → Super

### Layer keys
- `Caps`: tap = `Esc`, hold = *Navigation* layer.
- `Tab`: tap = `Tab`, hold = *System* layer (media + mouse).
- `Right Alt`: tap = `Alt`, hold = *Numbers/Symbols* layer.

### Navigation layer (Caps hold)
- Arrow keys on right hand.
- Home/End/PageUp/PageDown on the top‑right cluster.
- Function keys across the top row.
- Common edit shortcuts (Ctrl+Z/X/C/V/Y) on the left.

### Numbers/Symbols layer (Right Alt hold)
- Shifted numbers on the top row (`! @ # $ %` etc.).
- Plain numbers on the next row.
- Brackets, braces, slash, underscore, plus, equals, and pipe on the bottom row.

### System layer (Tab hold)
- Media controls (volume, play/pause, prev/next).
- Mouse movement + scrolling.
- Mouse buttons (left/right/middle).
- Print screen and menu keys.

### Gaming mode
- `game-on` stops Kanata (WASD normal).
- `game-off` restarts Kanata.

## Commands & Aliases
### System rebuilds
- `nrs` — `nh os switch ~/dotfiles`
- `nrb` — `nh os boot ~/dotfiles` (safe for NVIDIA)
- `nrt` — `nh os test ~/dotfiles`

### Manual rebuilds
- `rs` — `sudo nixos-rebuild switch --flake ~/dotfiles#nixos`
- `rb` — `sudo nixos-rebuild boot --flake ~/dotfiles#nixos`
- `rt` — `sudo nixos-rebuild test --flake ~/dotfiles#nixos`

### Home Manager
- `hms` — `home-manager switch --flake ~/dotfiles#sanskar`
- `hmd` — `home-manager dry-run --flake ~/dotfiles#sanskar`
- `hmu` — `home-manager switch --flake ~/dotfiles#sanskar --update-input nixpkgs`

### NVIDIA & gaming
- `nv-game` — NVIDIA offload env vars
- `steam-perf` — offload + gamemode (+ MangoHud by default)
- `perf-run` — offload + gamemode

### Shell utilities
- `ns`, `nu` — interactive `nix search` (stable/unstable) with `fzf` and `jq`
- `ni` — `nix shell nixpkgs#<pkg>`
- `dots` — open dotfiles in `$EDITOR`

### Safety & QoL
- `rm` → `trash-put`
- `ls` → `eza` variants
- `cat` → `bat`, `df` → `duf`, `du` → `dust`, `ps` → `procs`, `top` → `btop`

## AI Tooling
System‑wide AI CLIs (from `unstable`):
- `codex`, `gemini-cli`, `qwen-code`, `opencode`

LM Studio is wrapped to always offload to NVIDIA.

## Developer Stack
- Python 3.13 + pip/venv + uv
- Zig, Nim, Racket, Node.js, Bun
- Formatters: black, ruff, stylua, nixfmt, typstyle, prettier, shfmt
- Debuggers: gdb, lldb, valgrind
- Neovim uses LazyVim; plugins are *not* managed by Nix.

## Home Packages
- Firefox, Spectacle, Plasma NM, ncdu, nvtop, mesa-demos, fastfetch
- Nerd Fonts: JetBrains Mono, Fira Code

## Troubleshooting
- Boot slowness: `systemd-analyze blame | head -n 20`
- Bluetooth issues: `systemctl status bluetooth` and `rfkill list`
- NVIDIA check: `nvidia-smi` and `nvtop`
- Plasma issues: `journalctl -b --user -u plasma-plasmashell -u plasma-kwin_x11`

## Repo Structure
- `hosts/nixos/` — hardware + host config
- `modules/` — boot, desktop, nvidia, gaming, ai
- `home/sanskar/` — zsh, tools, git, dev, nvim
- `images/` — documentation assets

## Removed components
- Pentest tooling and helper scripts were removed.
- The old `scripts/` directory is gone.
- Wine auto-prefix runner removed with scripts cleanup.
