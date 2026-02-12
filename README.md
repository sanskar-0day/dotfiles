# 🖥️ Dotfiles — Debian 13 Hyprland + Distrobox Dev Setup
> ONE script to rule them all. Universal, battle-tested, and ultra-snappy.

This setup transforms a **Debian 13 (Trixie) minimal install** into a premium, hardware-agnostic Hyprland terminal-centric desktop with a containerized Arch dev environment.

## 🚀 One-Liner Install
```bash
sudo apt update && sudo apt install -y git && git clone https://github.com/sanskar-0day/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh
```

## 🧠 Architecture

| Component | Responsibility | Implementation |
|-----------|----------------|----------------|
| **Host** | Hardware & UI | Debian 13 (Trixie), Hyprland, Waybar, Wofi, Dunst |
| **GPU** | Universal Auto-Detect | Intel (iHD), AMD (RADV), NVIDIA (Proprietary + DRM) |
| **WiFi** | Stability Tuning | MediaTek/Generic power-save disabled, stable NM config |
| **Network** | Privacy/Speed | DNS-over-TLS (Quad9 + Cloudflare) |
| **Memory** | Optimization | ZRAM (zstd, dynamic sizing) + Swappiness tuning |
| **Containers** | Development | Distrobox (Arch Linux) + Home-exported CLI/GUI tools |
| **Management** | One Command | `dots` CLI (setup, update, sync, save, dev) |

## 🛠️ Performance & Stability
- **Auto GPU Detection**: Detects vendor at install time and generates optimized environment variables.
- **MediaTek Fixes**: Hardened WiFi settings to prevent drops on common MediaTek/Modern chipsets.
- **ZRAM**: Dynamic swap allocation using zstd compression for high-performance multitasking.
- **Auto-Updates**: Systemd timers handle daily `apt` and `flatpak` upgrades silently.

## ⌨️ Keybinds (The Essentials)
| Key | Action |
|-----|--------|
| `Super + Q` | Kitty Terminal |
| `Super + B` | Firefox (Flatpak) |
| `Super + E` | Thunar (File Manager) |
| `Super + D` | Power Launcher (Wofi) |
| `Super + C` | Close Window |
| `Super + Shift + L` | Lock Screen (Hyprlock) |
| `Alt + F4` | Wlogout (Power Menu) |
| `Print` | Screenshot (Area → Clipboard) |
| `Super + S` | Screenshot (Area → Edit/Swappy) |
| `Super + Shift + S` | Screenshot Menu |
| `Super + Shift + V` | Clipboard Manager (Cliphist) |

## 📦 Directory Structure
```
dotfiles/
├── install.sh          # Orchestrator (resume-aware, state tracking)
├── host/               # Host system: recipes, GPU detection, tuning
├── scripts/            # CLI helpers, dots CLI, clipboard/screenshot managers
├── hyprland/           # Config: animations, rules, binds (sourced fragments)
├── waybar/             # UI: Status bar configs & styling
├── distrobox/          # Rootless Arch container provisioning
└── [stow_packages]/    # Symlinked via GNU Stow
```

## 🔧 Post-Install Context
Use the `dots` command to manage your life:
- `dots update`: Pulls configs and updates every layer (Apt, Flatpak, Container).
- `dots dev`: Drops you into the rolling-release Arch container.
- `dots status`: Overview of everything running on the system.

## License
MIT
GPUEOF

