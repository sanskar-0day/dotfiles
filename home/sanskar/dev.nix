{ pkgs, ... }:
{
  # ── Global Development Tools ──────────────────────────────────
  # These are language-agnostic tools available globally.
  # Specialized stacks (Python, Node, Zig) are now managed via
  # per-project 'devShells' in flake.nix.
  home.packages = with pkgs; [
    # ── Version Control & Workflow ──
    git
    lazygit
    just # Modern make replacement
    tokei # Code statistics
    hyperfine # CLI benchmarking

    # ── Modern Runtimes & Managers ──
    uv # Fast Python package manager/runtime
    bun # Fast JS runtime
    
    # ── Formatters & Linters ──
    nixfmt-rfc-style # Nix
    shfmt # Shell
    shellcheck # Shell
    nodePackages.prettier # Web

    # ── System Diagnostics ──
    pciutils
    usbutils
    ethtool
    strace
    gdb
    valgrind
  ];
}
