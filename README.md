# Sanskar's NixOS Profile

A high-performance, stability‑first NixOS configuration for a hybrid AMD + NVIDIA laptop. This setup is surgically tuned for maximum desktop responsiveness under load, low-latency audio, and premium font rendering.

## 🚀 Performance & Stability Wins
- **Ananicy-cpp**: Automatic process re-nicing (KWin/Plasma stay smooth during heavy compiles).
- **EarlyOOM**: Prevents system freezes by aggressively killing heavy apps (LM Studio, Browser) before RAM exhaustion.
- **Micro-Tuning**:
  - **TCP BBR + FQ**: Significantly faster network throughput.
  - **I/O Schedulers**: `none` for NVMe (drive handles queuing) and `bfq` for SATA/Mechanical.
  - **zram (zstd)**: Faster and denser RAM compression.
  - **Thermald**: Prevents thermal throttling stutters on high-end laptops.
- **Nix Daemon Isolation**: Builds run at `idle` priority with a 60% CPU cap to ensure Zero Lag on the desktop.

## 🛠️ Developer Workflow
- **Lean Base System**: Global tools are limited to essentials (`git`, `just`, `uv`, `tokei`).
- **Per-Project `devShells`**: Specialized stacks (Data Science, Web Dev) are managed via `nix develop`.
  - `nix develop .#ds` — Python 3.13, Jupyter, NumPy, Pandas, Scikit-learn.
  - `nix develop .#web` — Node.js 22, Bun, Just.
- **Automated Checks**: `nix flake check` verifies the system config builds cleanly before deployment.
- **Tooling**:
  - `ghostty`: Ultra-fast GPU-accelerated terminal.
  - `yazi`: Terminal file manager with fast image previews.
  - `atuin`: Fuzzy, SQLite-backed shell history.
  - `zellij`: Modern terminal multiplexer (tab/pane management).
  - `obsidian`: Knowledge management and notes.

## 🖥️ Desktop & Graphics
- **KDE Plasma 6 (X11)**: Maximum stability for NVIDIA PRIME offload.
- **Surgical Graphics Tuning**:
  - **AMD iGPU**: DC FP16 filter enabled for smoother window compositing.
  - **NVIDIA dGPU**: Production driver with fine-grained power management and offload scripts.
  - **Vulkan/Mesa**: Full driver stack for DXVK, OpenCL, and Video Decode (vaapi).
- **Premium Font Rendering**: `fontconfig` tuned for Inter (UI) and JetBrains Mono (Code) with subpixel RGB antialiasing.

## ⚡ Quick Start
### Common Commands (Safe Rebuilds)
- `nrb` — Build boot entry (Safe for NVIDIA) then reboot.
- `hms` — Apply Home Manager changes (Plasma, Tools, Shell).
- `nrs` — Switch live system (use only for minor service changes).

### Custom Scripts
- `nvidia-offload <app>` — Runs an app on NVIDIA with stability/perf flags.
- `dots` — Open this repository in Neovim.

## 🧹 Housekeeping
- **Storage Safety**: `journald` and `coredump` are capped to 1GB each to prevent SSD bloat.
- **Auto-Optimise**: The Nix store automatically deduplicates hard links daily.
- **Garbage Collection**: Automated weekly cleanup of generations older than 14 days.

## ⌨️ Kanata Keyboard Layout
Custom home-row modifiers and tiered layers (Nav, System, Symbols) handled via `kanata`. Caps Lock is the primary navigation trigger.

---

## Repo Structure
- `hosts/nixos/` — Main host config + hardware definitions.
- `modules/` — Feature modules (Boot, Desktop, NVIDIA, Virtualization).
- `home/sanskar/` — User modules (Shell, Plasma, Dev, Git).
- `flake.nix` — Core orchestration, inputs, and `devShells`.
