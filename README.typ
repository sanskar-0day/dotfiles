#set page(paper: "a4", margin: 2cm)
#set text(font: "Libertinus Serif", size: 11pt)
#set heading(numbering: "1.")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  text(size: 20pt, weight: "bold")[#it.body]
  v(0.5cm)
}

#show heading.where(level: 2): it => {
  v(0.4cm)
  text(size: 15pt, weight: "bold")[#it.body]
  v(0.2cm)
}

#show heading.where(level: 3): it => {
  v(0.3cm)
  text(size: 12pt, weight: "bold")[#it.body]
  v(0.1cm)
}

#show link: it => text(fill: blue, weight: "bold")[#it]

#show raw.where(block: false): it => box(
  fill: luma(240), inset: 3pt, outset: 1pt, radius: 2pt,
)[#set text(font: "JetBrains Mono"); #it]

// Helper for info boxes
#let info(title, body) = block(
  width: 100%, radius: 4pt, stroke: 0.5pt + luma(150), inset: 10pt,
)[
  #if title != none [
    #text(weight: "bold", fill: luma(60))[#title]
    #v(2pt)
    #line(length: 100%, stroke: 0.3pt + luma(200))
    #v(4pt)
  ]
  #body
]


// ═══════════════════════════════════════
//   TITLE PAGE
// ═══════════════════════════════════════

#v(2fr)

#align(center, block(
  width: 85%, inset: 2cm, radius: 8pt, stroke: 1pt + luma(100), fill: luma(250),
)[
  #text(size: 32pt, weight: "bold")[Sanskar's Dotfiles]
  #v(0.3cm)
  #line(length: 40%, stroke: 1pt + luma(100))
  #v(0.3cm)
  #text(size: 16pt)[A Stability-First NixOS Setup]
  #v(1cm)
  #text(size: 10pt, fill: luma(120))[
    NixOS 25.11 . Kernel 6.12 . systemd-boot . Home Manager \
    #link("https://github.com/Sanskar-0day/dotfiles")[github.com/Sanskar-0day/dotfiles]
  ]
])

#v(2fr)


// ═══════════════════════════════════════
//   1. PHILOSOPHY
// ═══════════════════════════════════════

= Philosophy

This configuration is built around a single principle: *stability over novelty*. Every choice is made to ensure the system works reliably day after day without surprises.

== Core Principles

#info("Stability First")[
  The kernel is pinned to 6.12 and the NVIDIA driver uses the production branch. Unstable packages are only used where needed (AI tools, editors).
]

#v(0.3cm)

#info("Fast Boot")[
  Non-essential services are stripped out. systemd initrd parallelizes module loading. The target is a usable desktop within seconds.
]

#v(0.3cm)

#info("Minimal Surface Area")[
  SSH is off. Flatpak is off. Avahi, printing, Geoclue2, and PackageKit are all disabled. Fewer running services means fewer things that can break.
]

#v(0.3cm)

#info("Reproducibility")[
  The entire system, from bootloader to shell aliases, is defined in this repository. A fresh install can be configured to an identical state with a single command.
]

== Architecture

#grid(
  columns: (1fr, 1fr),
  gutter: 1cm,
  [
    *System (NixOS)*
    #v(0.2cm)
    #set text(size: 10pt)
    Kernel, bootloader, display manager, hardware drivers, system services, global packages. Defined across `hosts/` and `modules/`.
  ],
  [
    *User (Home Manager)*
    #v(0.2cm)
    #set text(size: 10pt)
    Shell, git, CLI tools, Neovim, development environments, user packages. Defined in `home/sanskar/`.
  ],
)


// ═══════════════════════════════════════
//   2. SYSTEM DESIGN
// ═══════════════════════════════════════

= System Design

== Boot

Uses *systemd-boot* with a 1-second timeout. systemd initrd enables parallel module loading. `amdgpu` loaded early for KMS. Quiet boot with suppressed kernel logs.

== AC-Aware Sleep

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8cm,
  [
    *Plugged In (AC)*
    #v(0.2cm)
    #set text(size: 10pt)
    - Lid close: *ignored*
    - Idle timeout: *disabled*
    - Suspend service: *masked* (cannot trigger)
  ],
  [
    *On Battery*
    #v(0.2cm)
    #set text(size: 10pt)
    - Lid close: *suspend*
    - Idle timeout: *30 minutes*
    - Suspend service: *unmasked*
  ],
)

== GPU Architecture

#grid(
  columns: (1fr, 1fr, 2fr),
  align: (left, left, left),
  [*Context*], [*GPU*], [*Mechanism*],
  [Desktop], [AMD Radeon], [Default rendering],
  [Games], [NVIDIA], [PRIME offload via env vars],
  [LM Studio], [NVIDIA], [Wrapped with env vars],
  [Video decode], [NVIDIA], [VAAPI hardware decode],
)

== Security

- `sudo` replaced with `doas` (alias preserved for muscle memory)
- Login failures trigger 4-second delay
- Boot shell disabled
- SSH completely off


// ═══════════════════════════════════════
//   3. GAMING
// ═══════════════════════════════════════

= Gaming

== Steam Launch Profile

#block(fill: luma(40), radius: 4pt, inset: 10pt)[
  #set text(font: "JetBrains Mono", size: 9pt)
  `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only gamemoderun %command%`
]

== GameMode

Feral's GameMode renices the game process, applies GPU optimizations, and inhibits the screensaver.

== Gaming Toggle

- `game-on` -- stops Kanata (normal WASD for gaming)
- `game-off` -- restarts Kanata (restores home-row modifiers)


// ═══════════════════════════════════════
//   4. KEYBOARD (KANATA)
// ═══════════════════════════════════════

= Keyboard (Kanata)

Kanata runs as a system-wide daemon, remapping every keypress before it reaches applications. This turns a standard keyboard into a layer-based efficiency machine with no extra hardware.

The config lives at `hosts/nixos/kanata.kbd` and is loaded automatically at boot via `services.kanata`.

== How Tap-Hold Works

Every home-row key has *two* functions depending on how you press it:

- *Tap* (press and release quickly) -- types the normal letter
- *Hold* (press and keep down) -- activates a modifier key

The timing is `200ms` for both the tap and hold thresholds. Fast typists will never accidentally trigger a modifier because holding a key for 200ms is longer than any normal keystroke during rapid typing.

This means you never need to move your fingers away from the home row to press Shift, Ctrl, Alt, or Super. For example:

- To type `Ctrl+C`: hold `D` (Ctrl), tap `C`, release `D`
- To type `Super+Space`: hold `A` (Super), tap `Space`, release `A`
- To type `Shift+H`: hold `F` (Shift), tap `H`, release `F`

== Home Row Modifiers

The eight home-row keys are split into left and right groups, mirroring the modifier layout of a standard keyboard:

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center,
    table.header(
      [*A*], [*S*], [*D*], [*F*], [*J*], [*K*], [*L*], [*;*],
    ),
    [Super], [Alt], [Ctrl], [Shift], [Shift], [Ctrl], [Alt], [Super],
    table.header([pink], [ring], [mid], [index], [index], [mid], [ring], [pink]),
  )
]

The *left pinky* (`A`) mirrors the *right pinky* (`;`), both map to Super. The *index fingers* (`F` and `J`) both map to Shift. This symmetry means modifier chords always use one hand on each side, just like a full-size keyboard.

== Layer Keys

Three keys unlock additional layers when held. Each acts as a normal key when tapped:

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1fr, 1.2fr, 1fr, 3.3fr),
    table.header([*Key*], [*Tap*], [*Hold*], [*Layer Contents*]),
    [`CapsLock`], [Esc], [Navigation], [Arrow keys, Home/End/PgUp/PgDn, F1--F12, Undo/Redo/Cut/Copy/Paste],
    [`Tab`], [Tab], [System], [Mouse movement (30px steps), mouse buttons, scroll wheel, media controls (volume, play/pause/prev/next), Print Screen],
    [`Right Alt`], [Alt], [NumSym], [Shifted numbers (`! @ # $ % ^ & *`), plain numbers (`1 2 3`), brackets, braces, math symbols (`+ = \\ |`)],
  )
]

== Navigation Layer (CapsLock Hold)

Holding `CapsLock` activates the Navigation layer. This layer puts productivity-critical keys under your fingertips without moving your hands:

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8cm,
  [
    *Left Hand (Shortcuts)*
    #v(0.2cm)
    #set text(size: 10pt)
    - `Z` = Ctrl+Z (Undo)
    - `X` = Ctrl+X (Cut)
    - `C` = Ctrl+C (Copy)
    - `V` = Ctrl+V (Paste)
    - `B` = Ctrl+Y (Redo)
    - `N` = Delete
    - `M` = Insert
  ],
  [
    *Right Hand (Navigation)*
    #v(0.2cm)
    #set text(size: 10pt)
    - `H/J/K/L` = Arrow keys (vim-style)
    - `U/I` = Home / End
    - `O/P` = Page Up / Page Down
    - `F1`--`F12` = Top row (function keys)
  ],
)

== System Layer (Tab Hold)

Holding `Tab` activates the System layer, providing mouse control and media keys:

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8cm,
  [
    *Mouse Control*
    #v(0.2cm)
    #set text(size: 10pt)
    - Arrow keys (`H/J/K/L`) move the cursor at 30px steps
    - `U/I` = scroll up / scroll down (3 lines)
    - `N/M` = scroll left / scroll right
    - `C/V/B` = left click / right click / middle click
  ],
  [
    *Media & System*
    #v(0.2cm)
    #set text(size: 10pt)
    - `Q/W/E/R/T` = Print Screen, Scroll Lock, Pause, Menu
    - `Z/X/C/V/B/N` = Volume Down/Up, Mute, Play/Pause, Prev Track, Next Track
    - `F1`--`F4` = F13--F16 (extra function keys)
  ],
)

== Number/Symbols Layer (Right Alt Hold)

Holding `Right Alt` activates the Number/Symbols layer. The top row becomes shifted symbols, the row below becomes plain numbers, and the bottom row has brackets and math:

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (12fr),
    align: center,
    table.header([*Top Row (Shifted)*]),
    raw("! @ # $ % ^ & * ( ) `"),
  )
]

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (12fr),
    align: center,
    table.header([*Number Row*]),
    raw("1 2 3 4 5 6 7 8 9 0"),
  )
]

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (12fr),
    align: center,
    table.header([*Symbol Row*]),
    raw("- _ = + [ ] { } \\ |"),
  )
]

== What Happens During Gaming

Kanata interferes with WASD movement because holding `W/A/S/D` triggers modifiers instead of typing. Two aliases solve this:

#info(none)[
  - `game-on` -- stops the Kanata service. All keys behave normally. WASD works as expected.
  - `game-off` -- starts the Kanata service. Home-row modifiers are restored.
]

These are *system-level* commands that require sudo/doas. Run `game-on` before launching any game that uses WASD, then `game-off` when done.


// ═══════════════════════════════════════
//   5. COMMANDS
// ═══════════════════════════════════════

= Commands & Aliases

== Rebuilds

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1fr, 2fr, 3fr),
    table.header([*Alias*], [*Command*], [*Notes*]),
    [`nrs`], [`nh os switch ~/dotfiles`], [Rebuild and switch],
    [`nrb`], [`nh os boot ~/dotfiles`], [Build boot entry (safe for NVIDIA)],
    [`nrt`], [`nh os test ~/dotfiles`], [Test, reverts on reboot],
    [`rs`], [`sudo nixos-rebuild switch ...`], [Direct rebuild (no nh)],
    [`rb`], [`sudo nixos-rebuild boot ...`], [Direct boot entry],
    [`hms`], [`home-manager switch ...`], [User config, no reboot],
    [`hmd`], [`home-manager dry-run ...`], [Dry run, see what changes],
    [`nixgc`], [`sudo nix-collect-garbage -d`], [Clean old generations],
    [`build-docs`], [`nix build .#docs`], [Generate Typst reference PDF],
  )
]

== AI Tooling

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1.2fr, 1.2fr, 3.6fr),
    table.header([*Tool*], [*Source*], [*Description*]),
    [`codex`], [unstable], [OpenAI coding agent CLI],
    [`gemini-cli`], [unstable], [Google Gemini CLI],
    [`qwen-code`], [unstable], [Qwen coding assistant],
    [`opencode`], [unstable], [OpenCode AI coding tool],
    [LM Studio], [unstable], [Local LLM GUI, NVIDIA-wrapped],
    [Ollama], [stable], [Local LLM runner, CUDA acceleration],
  )
]

== Shell Replacements

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1.5fr, 1.5fr, 3fr),
    table.header([*Original*], [*Replacement*], [*What It Adds*]),
    [`ls`], [`eza`], [Icons, git status, tree view],
    [`cat`], [`bat`], [Syntax highlighting, line numbers],
    [`rm`], [`trash-put`], [Move to trash, not permanent delete],
    [`find`], [`fd`], [Fast, ignores .git, color output],
    [`grep`], [`rg`], [Recursive, faster, better defaults],
    [`du`], [`dust`], [Visual bar chart of usage],
    [`top`], [`btop`], [Full UI with GPU, network],
    [`df`], [`duf`], [Colorful, human-readable disk usage],
    [`ps`], [`procs`], [Tree view, color, sockets],
    [`dig`], [`dog`], [Modern DNS client, colored output],
    [`sed`], [`sd`], [Intuitive regex, no backslash hell],
    [`hexdump`], [`hexyl`], [Colored hex viewer with ASCII hints],
    [`man`], [`tldr`], [Simplified, practical examples],
  )
]

== Additional Terminal Tools

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1.5fr, 1.5fr, 3fr),
    table.header([*Tool*], [*Category*], [*What It Does*]),
    [`fzf`], [Search], [Fuzzy finder for files, history, git],
    [`zoxide`], [Navigation], [Smarter `cd` with frecency learning],
    [`bat`], [Files], [Syntax highlighted `cat` with git integration],
    [`delta`], [Git], [Beautiful side-by-side diffs with syntax],
    [`lazygit`], [Git], [Full TUI for git operations],
    [`glow`], [Docs], [Render markdown in terminal],
    [`yazi`], [Files], [Rust file manager with previews],
    [`tmux`], [Terminal], [Vi-mode multiplexer with Dracula theme],
    [`atuin`], [History], [Synced shell history with fuzzy search],
    [`direnv`], [Dev], [Per-directory environment variables],
    [`btop`], [Monitor], [System monitor with GPU/network],
    [`bandwhich`], [Monitor], [Real-time bandwidth per process],
    [`tokei`], [Stats], [Code statistics by language],
    [`topgrade`], [System], [Upgrade everything at once],
    [`hyperfine`], [Dev], [Command benchmarking tool],
    [`entr`], [Dev], [Run commands on file changes],
    [`nurl`], [Nix], [Generate fetch expressions from repos],
    [`httpie`], [Network], [Modern curl with JSON support],
    [`mosh`], [Network], [Roaming SSH with local echo],
    [`lazydocker`], [Docker], [TUI for Docker management],
    [`dive`], [Docker], [Explore Docker image layers],
  )
]

== Neovim Configuration

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1.5fr, 1.5fr, 3fr),
    table.header([*Plugin*], [*Category*], [*What It Does*]),
    [LazyVim], [Framework], [Plugin manager with sane defaults],
    [Dracula], [Theme], [Dark theme across all tools],
    [Avante.nvim], [AI], [Cursor-like IDE with AI chat],
    [CodeCompanion], [AI], [Agentic chat and inline edits],
    [CopilotChat], [AI], [GitHub Copilot chat integration],
    [NeoCodeium], [AI], [Ultra-fast inline code completion],
    [nvim-tree], [Files], [File explorer with git status],
    [Fzf-lua], [Search], [Blazing fast fuzzy finder],
    [gitsigns], [Git], [Git changes in the gutter],
    [Flash.nvim], [Navigation], [Jump to any location fast],
    [nvim-treesitter], [Syntax], [Better syntax highlighting],
    [conform.nvim], [Format], [Auto-format on save],
    [nvim-lint], [Lint], [Linting for shell scripts],
    [nvim-dap], [Debug], [Debug adapter protocol],
    [trouble.nvim], [Diagnostics], [Better diagnostics list],
    [noice.nvim], [UI], [Beautiful command line and messages],
    [which-key], [UX], [Show pending keybindings],
    [mini.ai], [Text Objects], [Enhanced text objects],
    [persistence], [Sessions], [Session management],
    [nvim-autopairs], [Edit], [Auto-close brackets/quotes],
    [nvim-surround], [Edit], [Add/change surroundings],
    [better-escape], [UX], [jk/jj to escape insert mode],
    [indent-blankline], [Visual], [Indent guides],
    [vim-illuminate], [Visual], [Highlight word under cursor],
  )
]


// ═══════════════════════════════════════
//   6. DEVELOPMENT
// ═══════════════════════════════════════

= Development

== Languages

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1.2fr, 1fr, 3.8fr),
    table.header([*Language*], [*Version*], [*Notes*]),
    [Python], [3.13], [+ pip, virtualenv, Flask, uv],
    [Node.js], [22 LTS], [+ Bun as alternative runtime],
    [Zig], [latest], [+ ZLS language server],
    [Nim], [latest], [+ Nimble package manager],
    [Racket], [latest], [Scheme/Lisp family],
    [Common Lisp], [SBCL], [+ Roswell version manager],
  )
]

== Neovim LSP Servers

#block(stroke: 0.5pt + luma(200), radius: 4pt)[
  #table(
    columns: (1.5fr, 4.5fr),
    table.header([*Server*], [*Languages*]),
    [pyright], [Python type checking],
    [ruff], [Python linting and formatting],
    [lua-language-server], [Lua],
    [nil], [Nix expression language],
    [zls], [Zig],
    [nimlangserver], [Nim],
    [typescript-language-server], [TypeScript and JavaScript],
    [taplo], [TOML],
    [yaml-language-server], [YAML],
    [marksman], [Markdown],
    [sbcl], [Common Lisp],
  )
]

== Databases

#block(stroke: 0.5pt + luma(200), radius: 4pt, inset: 10pt)[
  *Neo4j Graph Database*
  #v(0.2cm)
  - Status: Systemd service
  - HTTP: http://localhost:7474
  - Bolt: bolt://localhost:7687
  - CLI: cypher-shell (via neo4j package)
  - Default credentials: neo4j / neo4j (change on first login)
]

=== Neo4j & Loom AI Agent

#block(stroke: 0.5pt + luma(200), radius: 4pt, inset: 10pt)[
  #grid(
    columns: (1.8fr, 4.2fr),
    gutter: 0.5cm,
    [*loom*], [Run Loom (loads API key from secrets)],
    [*loom-start*], [Starts Neo4j if needed, then launches Loom],
    [*neo4j-start*], [sudo systemctl start neo4j],
    [*neo4j-stop*], [sudo systemctl stop neo4j],
    [*neo4j-status*], [sudo systemctl status neo4j],
    [*neo4j-shell*], [cypher-shell -u neo4j -p neo4j],
    [*neo4j-browser*], [Opens http://localhost:7474],
  )
  #v(0.2cm)
  *Usage:*
  - Run `loom` or `loom-start` (auto-loads API key from ~/.secrets)
  - First time: type `/seed` in the REPL
]


// ═══════════════════════════════════════
//   7. TROUBLESHOOTING
// ═══════════════════════════════════════

= Troubleshooting

#info("Slow boot")[
  `systemd-analyze blame` -- identifies slowest services.
  `systemd-analyze critical-chain` -- shows boot dependency chain.
]

#v(0.3cm)

#info("NVIDIA not detected")[
  `nvidia-smi` confirms driver loaded. `nvtop` for GPU monitoring. Check `lsmod | grep nouveau` (should return nothing).
]

#v(0.3cm)

#info("Game runs on AMD instead of NVIDIA")[
  Ensure launch command includes the three PRIME offload env vars. Use `steam-perf` alias. Verify with `nvidia-smi` while game is running.
]

#v(0.3cm)

#info("Bluetooth won't pair")[
  `rfkill list` -- check soft-blocked. `bluetoothctl` -- interactive pairing. `systemctl restart bluetooth` -- reset daemon.
]

---

#v(2cm)
---

#v(2cm)

#align(center)[
  #text(size: 9pt, fill: luma(170), style: "italic")[
    Built with NixOS 25.11 . Last updated March 2026
  ]
]
