{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ── Databases ─────────────────────────────────────────────

    # PostgreSQL (uncomment if needed)
    # postgresql_16
    # pgcli                  # Better PostgreSQL CLI

    # Redis (uncomment if needed)
    # redis

    # ── Languages ──────────────────────────────────────────────
    # Python
    python313
    python313Packages.pip
    python313Packages.virtualenv
    python313Packages.flask
    python313Packages.sqlalchemy
    python313Packages.werkzeug
    uv # Ultra-fast Python package manager

    # Common Lisp
    sbcl
    roswell # CL implementation manager & script runner

    # Nim
    nim
    nimble # Nim package manager

    # Zig
    zig
    zls # Zig Language Server

    # Racket
    racket

    # JavaScript / TypeScript
    nodejs_22
    bun

    # ── Formatters & Linters ───────────────────────────────────
    black # Python formatter
    ruff # Ultra-fast Python linter + formatter
    stylua # Lua formatter
    nixfmt-rfc-style # Nix formatter
    typstyle # Typst formatter
    nodePackages.prettier # JS/TS/JSON/CSS/HTML formatter
    shellcheck # Shell script linter
    shfmt # Shell script formatter

    # ── Debug Adapters ─────────────────────────────────────────
    python313Packages.debugpy # Python debug adapter (DAP)

    # ── IDEs & Tools ───────────────────────────────────────────
    jetbrains.pycharm
    vscode
    typst # Modern LaTeX alternative
    just # Command runner (better Makefile)
    tokei # Code line counter
    gdb # GNU debugger
    lldb # LLVM debugger (for Zig/C)
    valgrind # Memory debugger
  ];
}
