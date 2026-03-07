# 🗡️ Sanskar's NixOS Dotfiles

A highly customized, modular NixOS 25.11 (Stable) configuration with an unstable overlay. Built from the ground up to be a **Gaming Powerhouse**, an **Elite Development Environment**, and a visually stunning **Unified Desktop**.

![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?logo=nixos&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-LazyVim-green.svg?logo=neovim)
![Theme](https://img.shields.io/badge/Theme-Dracula-purple.svg)
![Gaming](https://img.shields.io/badge/Gaming-Wine_Staging-red.svg?logo=wine)

---

## 🎨 Visual Identity
The system uses **Stylix** as a single source of truth for theming.
- **Theme**: Dracula
- **Fonts**: JetBrainsMono Nerd Font (Terminal/Code), Inter (UI), Noto Serif.
- **Boot Sequence**: 
  - **GRUB**: Custom Sekiro background.
  - **Plymouth**: Sleek, animated `lone` theme from the `adi1090x` collection.
- **Terminals & Tools**: KDE Plasma, GTK, `btop`, `bat`, `fzf`, `lazygit`, and `tmux` automatically sync to the Dracula palette.

## 🚀 Key Features

### 🎮 Gaming & Emulation
Built to handle heavy AAA Windows titles and Repacks (specifically FitGirl/Oodle decompressors) flawlessly on Linux.
- **Core Engine**: Wine Wow Staging (hybrid 64/32-bit), Winetricks, Vulkan, and DXVK.
- **Auto `.exe` Handler**: Double-clicking any `.exe` automatically invokes a custom `wine-run.sh` script. It creates an isolated Wine prefix per folder, installs `vcrun2022`/`dxvk`/`corefonts`, and launches the game natively.
- **FitGirl Memory Fixes**: The kernel is tuned (`vm.max_map_count = 2147483642`) and PAM limits set to `unlimited stack` to prevent OODLE decompression stack-overflows common in repacks.
- **Performance Modules**: Feral `gamemode` runs in the background. `gamescope` acts as a micro-compositor. `mangohud` provides Vulkan FPS overlays.
- **Launchers**: Steam, Lutris, Bottles, and Heroic are pre-installed.

### 💻 Elite Developer Environment
Configured for multi-language mastery with near-instant load times.
- **Neovim (LazyVim)**: A hybrid configuration. System dependencies (LSPs, formatters, debuggers) are managed by Nix, while `lazy.nvim` manages the plugins for speed.
  - *Supported via LSP/DAP*: Python (ruff, black, pyright, debugpy, uv, virtualenv), Zig (zls), Nim (nimlangserver), Common Lisp (sbcl, roswell), JS/TS (bun, prettier), Lua, Nix, Bash, Typst, and Markdown.
- **Modern CLI Replacement**: 
  - `eza` (ls)  |  `bat` (cat)  |  `zoxide` (cd)  |  `dust` (du)
  - `duf` (df)  |  `procs` (ps) |  `trash-put` (rm)|  `dog` (dig)
- **Tooling**: `tmux` (vim-keybindings), `btop`, `yazi` (TUI file manager), `lazygit`, `direnv` (Nix project autoloading), `nh` (colorized rebuilds), and `comma` (run any package instantly like `, cowsay`).
- **History**: `Atuin` replaces standard zsh history with an SQLite-backed fuzzy searchable database (Ctrl+R).

### 🛠️ Intelligent Build & Network Strategy
To combat ISP throttling and provide rock-solid system rebuilds:
- **Multi-Mirror Fallback**: Uses USTC, TUNA, SJTUG, and the official NixOS cache. If a download stalls for >5 seconds, it automatically cycles to the next mirror.
- **Safe Rebuilds**: Uses `boot` mode for updates rather than live `switch` to prevent NVIDIA display cache clears/crashes during module reloads.
- **Anti-Clobbering**: Home Manager is configured to automatically backup existing files with `.bak` extensions rather than crash the build, with explicit force overhangs for problematic files like `mimeapps.list`.
- **Resource Limits**: Builds are capped (`max-jobs = 4`, `cores = 4`) to ensure the host machine never OOMs while compiling from source.

### 🧠 Local AI Infrastructure
Running completely locally via systemd background services for lightning-fast loading without privacy leaks.
- **Ollama**: Runs as the `sanskar` user (avoiding strict systemd sandboxing issues), giving Native CLI and WebUI direct read/write access to HuggingFace GGUF models stored in `~/.ollama`. Accelerated by `unstable.ollama-cuda` for bleeding-edge Qwen 3.5 architecture support.
- **Open WebUI**: Local GUI at [http://localhost:8080](http://localhost:8080) for instant ChatGPT-like interaction. Configured with *no auth, no analytics, and no external connectivity pinging*.
- **LLaMA.cpp Tools**: `unstable.llama-cpp` is globally available for native CLI backend interaction (e.g., `llama-cli`, `llama-quantize`).

### 🌐 Connectivity & Services
- **Tailscale**: Mesh VPN for cross-device networking.
- **Cloudflare Warp**: Always-on encrypted DNS and tunneling mechanism.
- **KDE Connect**: Seamless Android/iOS bridging for clipboards, notifications, and file-drops.
- **Kanata**: System-level keyboard remapper running as a daemon.

---

## ⚙️ Installation & Operation

### Bootstrap Fresh System
If installing on a fresh generic NixOS system:
```bash
git clone https://github.com/sanskar-0day/dotfiles ~/dotfiles
cd ~/dotfiles
./setup.sh
```

### Daily Usage Aliases (ZSH)
Nix operations have been wrapped into safety-checked ZSH aliases:

| Alias | Command | Purpose |
|-------|---------|---------|
| `nrs` | `nixos-rebuild switch ...` | The standard update command. Safely builds and **applies immediately**. |
| `nrb` | `nixos-rebuild boot ...` | Builds the system but **requires a reboot to activate**. Safest option to prevent display crashes on heavy updates. |
| `nup` | `nix flake update && nrs` | Pulls latest packages from flake.lock and stages/applies the build. |
| `nrt` | `nixos-rebuild test ...` | Builds and applies changes temporarily. Lost on next reboot. |
| `ns`  | `nix search nixpkgs...` | Fuzzy search stable packages via `fzf` UI. |
| `nu`  | `nix search unstable...` | Fuzzy search unstable overlay packages. |
| `ni`  | `nix shell ...` | Drop into an ephemeral shell providing the requested package. |
| `ndiff`| `nvd diff ...` | Shows exactly what packages were upgraded/added between system generations. |
| `nlog` | `nix-env --list-generations...`| Show local system history. |
| `nclean`| `nix-collect-garbage -d ...` | Wipe old generations and optimise store space. `nix.gc` also runs automatically every 15 days. |
| `dots` | `cd ~/dotfiles && $EDITOR` | Jump directly into the repo and start editing. |

---

## 📂 Repository Architecture

```text
.
├── flake.nix                  # Flake entry point (Inputs, Overlays, HM Injection)
├── hosts/nixos/               # Hardware and system-wide configurations
│   ├── default.nix            # Core Nix settings, Mirrors, SysPackages, Services
│   ├── hardware.nix           # Auto-generated FS mounts and kernel modules
│   └── kanata.kbd             # Keyboard remapping config
├── modules/                   # Reusable system building blocks
│   ├── boot.nix               # GRUB, Plymouth (adi1090x), Silent Boot parameters
│   ├── desktop.nix            # SDDM, KDE Plasma 6, Audio, KDE Connect, Bluetooth
│   ├── gaming.nix             # Wine Staging, Gamescope, sysctl Memory Fixes
│   ├── nvidia.nix             # Proprietary drivers, PRIME Offload, unfree flags
│   ├── stylix.nix             # Global Theming Engine (Dracula Base16)
│   └── virtualization.nix     # Docker, Libvirtd, QEMU/KVM config
├── home/sanskar/              # Userspace configurations (Home Manager)
│   ├── default.nix            # HM Entry point, xdg.mimeApps (.exe handler)
│   ├── shell.nix              # ZSH, Starship prompt, Aliases, fuzzy search fns
│   ├── tools.nix              # CLI utilities (bat, btop, fzf, tmux, atuin, yazi)
│   ├── git.nix                # Gitconfig, delta (diff viewer)
│   ├── dev.nix                # Compilers, LSPs, REPLs, Formatters, Debug Adapters
│   ├── nvim.nix               # System-level Neovim injected dependencies
│   └── nvim/                  # LazyVim Lua configuration mapping
└── scripts/                   # Standalone bash utilities
    ├── import-gguf.sh         # Inject raw HF GGUF models directly into Ollama
    ├── install-games.sh       # Interactive terminal UI for installing FitGirl repacks
    └── wine-run.sh            # The magic script powering the double-click .exe flow
```

---

## ⌨️ Deep-Dive: Keymaps & Editor Ergonomics

This system avoids the mouse wherever possible. It is built strictly around **Kanata** (for system-wide modifiers) and **LazyVim** (for modal text editing). 

### 🐙 Kanata (System-Wide Layering)
Kanata runs a highly customized layer-based ergonomic system optimized heavily for the home row. It utilizes `tap-hold` semantics (tapping outputs a normal key, holding acts as a modifier). **This applies globally across the entire OS.**

**Modifier Triggers:**
- **`Caps Lock` (Hold)** → Activates **Nav Layer**
  - *(Tapping `Caps Lock` normally outputs `ESC`)*
- **`L-Alt` / `R-Alt` (Hold)** → Activates **Num/Sym Layer**
- **`Tab` (Hold)** → Activates **System Layer**

**Layer Breakdown:**

#### 1. Nav Layer (Hold `Caps Lock`)
This layer turns your right hand into a powerful navigation cluster and your left hand into a macro pad workspace.
- **Navigation (Right Hand):** `H J K L` act as standard `Left Down Up Right`. 
- **Paging / Text Jump:** `Y U I O` act as `Home PgUp PgDn End`.
- **Delete / Insert:** `M` maps to `Del`, `,` maps to `Ins`.
- **Macros (Left Hand):** The bottom row handles system clipboard and history.
  - `Z` = Undo (`Ctrl+Z`)
  - `X` = Cut (`Ctrl+X`)
  - `C` = Copy (`Ctrl+C`)
  - `V` = Paste (`Ctrl+V`)
  - `Y` = Redo (`Ctrl+Y`)
- **F-Keys (Top Row):** Numbers `1-0` become `F1` through `F12`.

#### 2. Num/Sym Layer (Hold `Left/Right Alt`)
Turns the left and right hand banks into an integrated numpad and symbol input system without needing to reach the top row.
- **Numbers (Right Hand):** Under your fingers `J K L ;` are `7 8 9 0`, with the row above being `1 2 3 4 5 6`.
- **Symbols (Right/Left Hand):** Access to brackets `[ ] { }` and backslashes `\ |` directly from the home row to avoid pinky stretching.
- **Shifted Modifiers:** Holding Left/Right Shift while in this layer automatically converts the home-row numbers into their `Shift+N` symbols (e.g., `!` `@` `#` `$` `%` `^` `&` `*`), completely removing the awkward top-row diagonal pinky stretch.

#### 3. System Layer (Hold `Tab`)
Used exclusively for hardware control and mouse simulation.
- **Media Control (Bottom Row):** Left to right triggers `VolDown VolUp Mute Play/Pause Prev Next`.
- **Mouse Simulation (Right Hand):** If you don't want to use your trackpad/mouse, you can control the X11/Wayland pointer via `I K J L` (Up/Down/Left/Right). 
  - `M , .` = Left Click / Right Click / Middle Click.
  - `U O /` = Scroll Up / Scroll Down / Scroll Side-to-Side.

---

### 📝 Neovim (LazyVim + Native Setup)
The Neovim instance utilizes the pristine **LazyVim** distribution. It is structured around `<Space>` acting as a global Leader key. *If in Insert Mode, tap `Caps Lock` (mapped to ESC) to return to Normal mode.*

#### 🧭 Basic Motions (Vim Native)
- `w` / `b` : Jump forward / backward by word.
- `e` / `ge` : Jump to end of word / previous end of word.
- `0` / `^` / `$` : Jump to start of line / first non-blank character / end of line.
- `gg` / `G` : Jump to the very top / very bottom of the file.
- `} / {` : Jump down / up by paragraph (empty line blocks).
- `%` : Jump to matching bracket `()`, `{}`, `[]`.
- `f{char}` / `F{char}` : Find (jump to) the next/prev occurrence of `{char}` on the current line.
- `t{char}` / `T{char}` : Jump up *until* `{char}` on the current line.
- `;` / `,` : Repeat the last `f/F/t/T` jump forward / backward.

#### ✂️ Editing & Manipulation (Vim Native)
- `dd` / `D` : Delete entire line / delete from cursor to end of line.
- `yy` / `y$` : Yank (copy) entire line / yank to end of line.
- `p` / `P` : Paste after cursor / paste before cursor.
- `x` / `X` : Delete character under cursor / delete character before cursor.
- `s` : Delete character and substitute (enters Insert mode).
- `c` : Change operator (e.g. `cw` changes word, `cc` changes line, `c$` changes to end of line).
- `J` : Join current line with the line below it.
- `u` / `Ctrl + r` : Undo / Redo.
- `.` : Repeat the last editing action.

#### 👁️ Visual Mode & Text Objects
- `v` / `V` / `Ctrl + v` : Visual mode (character) / Visual Line mode / Visual Block mode.
- `>` / `<` : Indent / De-indent selected lines.
- `viw` / `vaw` : Select **i**nner **w**ord / select **a** **w**ord (includes trailing space).
- `vi"` / `vi(` : Select everything inside quotes `""` / parentheses `()`.
- `cit` / `yat` : **C**hange **i**nner HTML **t**ag / **Y**ank **a**round HTML **t**ag.

#### 🔍 Search & Replace
- `/` / `?` : Search forward / backward in current file.
- `n` / `N` : Jump to next / previous search result.
- `*` / `#` : Search for the exact word currently under the cursor (forward / backward).
- `:%s/foo/bar/g` : Replace 'foo' with 'bar' globally across the entire file.
- `:%s/foo/bar/gc` : Same as above, but **c**onfirm each substitution.

#### 📁 Project Navigation & UI (LazyVim)
- `<Leader> e` : Toggle **Neo-Tree** (file explorer drawer on the left).
- `<Leader> /` : **Global Regex Search**. Search across the *whole project* (Telescope / ripgrep).
- `<Leader> f f` : **Find Files**. Fuzzy search the current directory for filenames.
- `<Leader> f r` : **Recent Files**. Pull up a list of files you were recently working on.
- `<Leader> s /` : **Buffer Search**. Telescope UI search for a word only in the current file.
- `Ctrl + /` : Toggle the floating generic terminal.

#### 🪟 Windows & Buffers
- **Splits:**
  - `<Leader> -` : Horizontal split.
  - `<Leader> |` : Vertical split.
  - `Ctrl + h/j/k/l` : Move seamlessly between open splits and windows.
  - `Ctrl + Up/Down/Left/Right` : Resize the current split window.
- **Buffers (Tabs):**
  - `<Leader> b d` : Delete the buffer (safely close the current file without closing the split).
  - `Shift + h` / `Shift + l` : Cycle left and right cleanly through your open files.

#### 🤖 Coding & LSP Intelligence
- `K` : **Hover docs**. Shows the full method signature, types, and docstrings of whatever your cursor is on.
- `g d` : **Go to Definition**. Jump instantly into the source code of a function/class.
- `g r` : **Find References**. List everywhere in the project this function/variable is called.
- `g R` : **Rename**. Intelligently rename a variable across the entire project scope.
- `<Leader> c a` : **Code Action**. Pops open a menu to let the LSP auto-fix errors, auto-import missing modules, or restructure code.
- `<Leader> c f` : **Format**. Format the current file securely using configured Nix formatters (e.g. `black`, `nixfmt`).
- `] d` / `[ d` : Jump to the next/previous diagnostic error/warning.
- `<Leader> c d` : Show line diagnostics in a floating window.

#### 🐙 Git & Surround
- `<Leader> g g` : Opens **LazyGit**, a GUI dashboard for staging/committing files instantly.
- `] h` / `[ h` : Jump to next / previous Git hunk (unchanged, modified, or deleted block) in the file.
- `<Leader> g p` : Preview the Git hunk under cursor.
- `<Leader> g r` : Reset/discard the Git hunk under cursor.
- **Surround (`ys`, `cs`, `ds`):**
  - `ys iw "` : Surround inner word with quotes.
  - `cs ' "` : Change surrounding single quotes to double quotes.
  - `ds "` : Delete surrounding quotes.

#### 🧠 Macros, Marks & AI
- `q{char}` : Start recording a macro to register `{char}` (e.g. `qa`). Press `q` again to stop.
- `@{char}` : Play back the macro stored in `{char}`.
- `@@` : Replay the last played macro.
- `m{char}` : Drop a mark at the current cursor position.
- `'{char}` : Jump back to the exact line of the stored mark.
- `:OpenCode` : Launches the `opencode.nvim` copiloting interface right inside the editor to chat with Ollama.

---

## 🏗️ Custom Workflows inside the Dotfiles

### 🍷 The "Double-Click .exe" Gaming Pipeline
This workflow entirely eliminates the need to manually configure Lutris/Bottles for random downloaded executables or FitGirl repacks.
1. Download any Windows `.exe` setup file or portable game.
2. Double-click it directly inside Dolphin (KDE File Manager).
3. Under the hood, **`xdg.mimeApps`** catches the `.exe` extension and routes it internally to `~/dotfiles/scripts/wine-run.sh`.
4. `wine-run.sh` evaluates the folder the `.exe` is in. It automatically generates an isolated, headless Wine prefix specifically for that folder (`.wine-prefix`).
5. It configures the prefix with `Winetricks` (injecting `dxvk`, `vcrun2022`, and `corefonts`), executes `gamemode`, sets memory stack limits to prevent OODLE decompression crashes, and runs the game via Wine Wow Staging. 

### 🧠 The Standalone GGUF Pipeline
If you find a raw model on HuggingFace but don't want to use the WebUI to download it:
1. Download the `.gguf` file to your drive.
2. Run `~/dotfiles/scripts/import-gguf.sh <path-to-file> <model-name>`
3. The script dynamically generates a Modelfile wrapper and permanently registers it into your system-level Ollama service without shifting directories.
4. It is instantly available in CLI (`ollama run <model-name>`) and inside Open WebUI (`http://localhost:8080`).
