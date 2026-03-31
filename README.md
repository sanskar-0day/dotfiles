# Sanskar's NixOS Dotfiles

> My entire operating system, declaratively — from the bootloader to the shell prompt.
> One repo, one command, identical machines every time.

This is a flake-based NixOS configuration that I use as my daily driver on an AMD+NVIDIA hybrid laptop. It's not a minimal example or a starter template — it's a living system that I actively develop, game on, run local LLMs with, and write code in every day.

I first switched to NixOS because I was tired of reinstalling my Linux setup every few months after some `apt upgrade` inevitably broke something. The idea that your entire OS can be version-controlled and atomically rebuilt appealed to me immediately. Over the past year, I've gone from a basic `configuration.nix` to the modular, flake-based setup documented here.

---

## Architecture Overview

The configuration follows a clear separation between **system-level** (NixOS modules) and **user-level** (Home Manager) concerns:

```
dotfiles/
├── flake.nix                 # Entry point — pins nixpkgs, wires inputs
├── flake.lock                # Reproducible dependency lock
│
├── hosts/
│   └── nixos/
│       ├── default.nix       # Main system config (networking, kernel, services)
│       ├── hardware.nix      # Auto-generated hardware scan
│       └── kanata.kbd        # Keyboard remapping (home-row mods)
│
├── modules/                  # Feature-specific system modules
│   ├── boot.nix              # systemd-boot, kernel params, plymouth, sysctl
│   ├── desktop.nix           # Plasma 6, PipeWire, portals, bloat removal
│   ├── nvidia.nix            # PRIME offload, Vulkan, VAAPI, power mgmt
│   ├── gaming.nix            # Steam, Proton-GE, GameMode, Gamescope
│   ├── ai.nix                # LM Studio NVIDIA wrapper
│   ├── virtualization.nix    # Docker, libvirtd/QEMU, Distrobox
│   └── typst.nix             # Typst toolchain + fonts
│
├── home/
│   └── sanskar/
│       ├── default.nix       # User packages, session vars, XDG
│       ├── shell.nix         # Zsh + Starship prompt
│       ├── zshrc             # Hand-written shell config (functions, keybinds)
│       ├── git.nix           # Git + Delta diffs + GitHub CLI
│       ├── tools.nix         # CLI toolbelt (50+ modern replacements)
│       ├── nvim.nix          # Neovim + LazyVim + LSP servers
│       ├── dev.nix           # Global dev tools (uv, bun, formatters)
│       ├── plasma.nix        # Declarative KDE Plasma config (plasma-manager)
│       └── fastfetch/        # System info display
│
├── devshells/                # Per-project development environments
│   ├── default.nix           # Shell registry
│   ├── ds.nix                # IITM Data Science stack (Flask, SQLite, Vue)
│   └── web.nix               # Web freelancing (Node, Bun)
│
├── docs/
│   └── builder.nix           # Auto-generated Typst PDF from live config
│
├── setup.sh                  # Bootstrap script for fresh installs
└── README.typ                # This repo's documentation in Typst
```

### Why This Structure Matters

Every feature is isolated into its own module. Want to remove gaming from the system? Delete one import line. Need to test the config on a machine without NVIDIA? Skip `nvidia.nix`. This is the power of NixOS's module system — composability without hidden dependencies.

The `flake.nix` is the orchestrator. It pins `nixpkgs` stable (25.11) and unstable, injects Home Manager as a NixOS module (not standalone, so system and user config rebuild together), and exposes dev shells and a documentation builder as first-class outputs.

---

## Flake Inputs & Outputs

| Input | Purpose |
|---|---|
| `nixpkgs` (25.11 stable) | System packages, kernel, drivers |
| `nixpkgs-unstable` | Bleeding-edge packages (AI tools, editors) |
| `home-manager` (25.11) | User-space configuration management |
| `nix-index-database` | Pre-built package index for `comma` |
| `plasma-manager` | Declarative KDE Plasma settings |

The flake exposes:
- **`nixosConfigurations.nixos`** — the full system build
- **`homeConfigurations.sanskar`** — standalone Home Manager (for non-NixOS use)
- **`packages.x86_64-linux.docs`** — auto-generated Typst PDF
- **`devShells.x86_64-linux.{ds,web}`** — project development environments
- **`checks.x86_64-linux.nixos-config`** — CI-friendly build verification

---

## Module Deep Dives

### Boot & Kernel (`modules/boot.nix`)

The boot configuration is where I spent the most time because it directly affects daily experience. Key decisions:

- **systemd-boot** over GRUB — faster, simpler, no config file generation delay
- **systemd initrd** — parallelizes module loading, shaves ~2s off boot
- **Kernel 6.12** pinned explicitly — I don't want a kernel update breaking NVIDIA
- **`mitigations=off`** — Spectre/Meltdown patches disabled for ~5–10% perf uplift (acceptable risk on a personal laptop)
- **Plymouth (breeze)** — silent boot with a splash screen, `quiet` + `loglevel=3`
- **`zstd -6` initrd compression** — 10× faster rebuild than `-19`, identical decompression speed
- **systemd timeouts set to 5s** — if a service can't start in 5 seconds, something is wrong

The sysctl tuning is split between `boot.nix` (network + VM params) and `hosts/nixos/default.nix` (TCP buffer sizes). This is intentional — boot-level params are about kernel behavior, host-level params are about network optimization for this specific machine.

### GPU Architecture (`modules/nvidia.nix`)

This is an AMD Ryzen laptop with an NVIDIA dGPU. The setup uses PRIME Offload:

| Context | GPU | Why |
|---|---|---|
| Desktop / browser | AMD iGPU | Lower power, no fan noise |
| Games | NVIDIA dGPU | `nvidia-offload` wrapper script |
| LM Studio (AI) | NVIDIA dGPU | CUDA acceleration via `lmstudio-nvidia` |
| Video decode | NVIDIA dGPU | Hardware VAAPI decode |

The `nvidia-offload` script is more than just `__NV_PRIME_RENDER_OFFLOAD=1`. It includes:
- `__GL_YIELD=USLEEP` — prevents the driver from busy-spinning at 100% CPU
- `__GL_MaxFramesAllowed=1` — prevents frame queue crashes on heavy loads
- `__GL_THREADED_OPTIMIZATIONS=1` — multithreaded OpenGL driver
- Shader cache persistence — eliminates first-launch stutters

Fine-grained power management is enabled, so the dGPU powers down completely when not in use. This matters a lot for battery life.

### Desktop (`modules/desktop.nix`)

KDE Plasma 6 on X11. I know Wayland is the future, but NVIDIA + Wayland + Plasma still has enough rough edges (screen flicker, XWayland scaling, SDDM crashes) that X11 is the pragmatic choice for daily use.

Opinionated decisions here:
- **Baloo disabled** — KDE's file indexer causes constant disk I/O and stutter. I use `fd` and `ripgrep` instead.
- **Akonadi disabled** — PIM service adds 300MB+ RAM usage for features I don't use.
- **Bloat removed** — Elisa, Discover, KHelpCenter, and others are excluded from the Plasma install.
- **PipeWire at 64-quantum** — 1.3ms audio latency (default is 21ms). Notable for gaming and music.
- **X11-specific NVIDIA vars** — `KWIN_TRIPLE_BUFFER`, `KWIN_X11_NO_SYNC_TO_VBLANK` for tearing-free compositing.

### Gaming (`modules/gaming.nix`)

Full gaming stack:
- **Steam** with Proton-GE, Gamescope micro-compositor, and remote play
- **GameMode** — auto-renices the game process, pushes NVIDIA to max clocks
- **`vm.max_map_count = 2147483642`** — required for large Wine/Proton games
- **Unlimited stack size** — prevents crashes in heavily compressed game repacks
- **`game-on` / `game-off`** aliases — toggles Kanata so WASD keys work normally

### AI Infrastructure (`modules/ai.nix`)

LM Studio is wrapped with a `lmstudio-nvidia` script that forces CUDA inference on the dGPU. Combined with `gamemoderun`, this gives maximum GPU clocks during inference. The model directory (`~/models`) is symlinked into LM Studio's cache via a Home Manager activation script.

The system also includes CLI tools from unstable: `codex`, `gemini-cli`, `qwen-code`, `opencode`.

### Virtualization (`modules/virtualization.nix`)

Docker is socket-activated (doesn't start on boot — starts on first `docker` command). Logs are capped with `local` driver to prevent SSD bloat. QEMU/KVM is set up with TPM emulation for Windows 11 VMs.

---

## Shell Environment

### Zsh

The shell config is split between `shell.nix` (Home Manager options) and `zshrc` (hand-written configuration). This is a deliberate separation — Home Manager handles the declarative parts (history size, completions, plugins), and the `zshrc` handles imperative bits (keybindings, functions, integrations).

Highlights:
- **100k history entries** with deduplication and space-ignoring
- **Emacs keybindings** — I use vim in the editor, emacs in the shell (muscle memory)
- **`fancy-ctrl-z`** — Ctrl-Z toggles between foreground and background (no more typing `fg`)
- **Vivid-generated LS_COLORS** — Dracula-themed directory listings
- **zoxide** — frecency-based `cd` that learns your most-used directories
- **`any-nix-shell`** — keeps zsh as the shell inside `nix-shell` (instead of bash)
- **Auto shell.nix** — `cd` into a directory with `shell.nix` and it activates automatically

### Modern CLI Replacements

| Original | Replacement | What Changes |
|---|---|---|
| `ls` | `eza` | Icons, git status, tree view |
| `cat` | `bat` | Syntax highlighting, Dracula theme |
| `rm` | `trash-put` | Moves to trash, recoverable |
| `find` | `fd` | Fast, respects `.gitignore` |
| `grep` | `ripgrep` | Recursive by default, faster |
| `du` | `dust` | Visual bars, sorted by size |
| `top` | `btop` | GPU, network, process tree |
| `df` | `duf` | Colorful, human-readable |
| `ps` | `procs` | Tree view, color, sockets |
| `sed` | `sd` | Intuitive regex, no escaping hell |
| `hexdump` | `hexyl` | Colored hex + ASCII |
| `man` | `tldr` | Practical examples first |

### Starship Prompt

Minimal prompt showing: directory → git branch → git status → nix shell indicator. The NixOS snowflake icon (󱄅) replaces the default `$` symbol, with green/red/purple variants for success/error/vi-mode.

### Shell.nix Auto-Activation

A `chpwd` hook detects when you `cd` into a directory containing `shell.nix` and enters the nix-shell automatically. It tracks the current shell via `_NIXSHELL_DIR` so it won't re-enter if you're already inside. This is incredibly useful for coursework projects that use `shell.nix` instead of flake devShells.

---

## Development Environments

### Per-Project Dev Shells

Instead of polluting the global environment with language runtimes, each project stack is defined as a flake devShell:

**`nix develop .#ds`** — IITM BS Data Science stack:
- Python 3 with Flask, SQLAlchemy, Celery, Redis, marshmallow, JWT auth
- SQLite + litecli + sqldiff
- Node.js 22 (Vue frontend)
- Redis server (Celery broker)
- Testing: pytest, coverage, factory-boy
- Auto-configured aliases: `flask-run`, `redis-start`, `db-shell`, `celery-worker`

**`nix develop .#web`** — Web freelancing:
- Node.js 22, Bun, Git, Just

The `dev()` function in zshrc lists available shells when called without arguments:
```bash
$ dev
> Available devShells:
ds
web
```

### Neovim

LazyVim-based setup with:
- **12 LSP servers** — Python, Lua, Nix, TypeScript, Zig, Nim, TOML, YAML, Markdown, Lisp
- **4 AI plugins** — Avante (Cursor-like), CodeCompanion, CopilotChat, NeoCodeium
- **Nix-managed dependencies** — all LSPs, formatters (black, stylua, nixfmt, prettier), and debug adapters are declared in `nvim.nix`, not installed via Mason

---

## Keyboard (Kanata)

Kanata runs as a systemd service, intercepting all keystrokes system-wide. The core idea is **home-row modifiers** — the eight home-row keys double as modifier keys when held:

```
          Left                           Right
 ┌──────┬──────┬──────┬──────┐ ┌──────┬──────┬──────┬──────┐
 │  A   │  S   │  D   │  F   │ │  J   │  K   │  L   │  ;   │
 │Super │ Alt  │ Ctrl │Shift │ │Shift │ Ctrl │ Alt  │Super │
 └──────┴──────┴──────┴──────┘ └──────┴──────┴──────┴──────┘
```

Three layer keys expand the keyboard further:
- **CapsLock** (hold) → Navigation layer: vim-style arrows, Home/End/PgUp/PgDn, F1–F12, clipboard shortcuts
- **Tab** (hold) → System layer: mouse movement (keyboard-driven cursor), media controls, scroll
- **Right Alt** (hold) → NumSym layer: numbers, shifted symbols, brackets, math operators

All three produce their normal character on tap. The 200ms tap-hold threshold is fast enough that it never fires during regular typing.

---

## Documentation Pipeline

Running `nix build .#docs` generates a complete Typst PDF of the configuration. The `docs/builder.nix` reads every `.nix` file at evaluation time and interpolates them into a Typst template — meaning the documentation is always in sync with the code. No stale docs.

The output is a styled reference guide with a title page, table of contents, and formatted code blocks for every module.

---

## Bootstrapping

For a fresh NixOS install:

```bash
bash <(curl -sL https://raw.githubusercontent.com/sanskar-0day/dotfiles/main/setup.sh)
```

The script:
1. Checks for root (refuses to run as root)
2. Verifies internet connectivity
3. Enables flakes in `~/.config/nix/nix.conf`
4. Installs git if missing
5. Clones this repo (or pulls if it already exists)
6. Copies `hardware-configuration.nix` into the repo
7. Prints the rebuild command

After that: `sudo nixos-rebuild boot --flake ~/dotfiles#nixos`, reboot, and you're done.

---

## Common Commands

| Alias | What It Does |
|---|---|
| `nrs` | Rebuild + switch (live, use for small changes) |
| `nrb` | Rebuild + boot entry (safe for NVIDIA driver changes) |
| `hms` | Home Manager switch (shell, tools, Plasma) |
| `ds` | Enter data science dev shell |
| `web` | Enter web dev shell |
| `nvidia-offload <app>` | Run app on NVIDIA dGPU |
| `game-on` / `game-off` | Toggle Kanata for gaming |
| `bt-fix` | Reset Bluetooth + audio stack |
| `build-docs` | Generate Typst PDF from config |
| `dots` | Open this repo in Neovim |

---

## Performance Tuning Summary

| Area | Optimization | Impact |
|---|---|---|
| CPU scheduler | ananicy-cpp with CachyOS rules | KWin stays responsive under load |
| Memory | EarlyOOM at 5% threshold | Prevents full lockups |
| Memory | zram with zstd at 50% | Effective RAM nearly doubled |
| I/O | NVMe → `none`, SATA → `bfq` | Correct scheduler per device |
| Network | TCP BBR + FQ qdisc | Measurably faster downloads |
| Network | TCP Fast Open | Reduced connection latency |
| Nix daemon | 60% CPU cap, idle priority | Builds never lag the desktop |
| Boot | systemd initrd, 5s timeouts | Sub-10s to desktop |
| Fonts | Subpixel RGB, slight hinting | Crisp text on LCD panels |

---

## What I Learned Building This

NixOS has a steep learning curve, and I hit most of the sharp edges. Some hard-won lessons:

- **NVIDIA on NixOS is a minefield.** The open kernel module, production vs beta driver branches, PRIME offload vs PRIME sync, Wayland vs X11 — I tried every combination. The current config is the result of months of testing.
- **Home Manager as a NixOS module vs standalone** — I use both. The NixOS module integrates tighter (rebuilds together), but the standalone config is useful for quick user-level changes.
- **`nix develop` vs `nix-shell`** — flake dev shells are faster and more reproducible. But `nix-shell` works with `shell.nix` files that don't require a flake, which is why the auto-activation hook exists.
- **Separating system and user concerns is not just organization** — it prevents permission issues, makes Home Manager rebuilds fast (no sudo needed), and lets you test user changes without risking the system.
- **The Nix store is your friend, not your enemy** — `auto-optimise-store` deduplicates hard links. `nh clean` with `keep-since 4d` keeps disk usage reasonable. Don't be afraid of it.

---

## Hardware

- **CPU**: AMD Ryzen (with `kvm_amd` for virtualization)
- **iGPU**: AMD Radeon (default rendering, desktop compositing)
- **dGPU**: NVIDIA (PRIME Offload, production driver, fine-grained PM)
- **WiFi**: TP-Link T3U Plus (rtl88x2bu driver, compiled from kernel modules)
- **Internal WiFi**: MediaTek mt7921e (blacklisted — unreliable, external adapter used instead)
- **Storage**: NVMe SSD with FSTRIM enabled
- **Audio**: PipeWire with 64-quantum (1.3ms latency)

---

*Built with NixOS 25.11 · Kernel 6.12 · systemd-boot · Home Manager · March 2026*
