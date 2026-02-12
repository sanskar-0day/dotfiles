#!/usr/bin/env bash
# distrobox/setup-dev.sh — Dev tool setup (runs INSIDE the Arch container)
# This is the heart of the dev environment. Everything non-essential
# to the host lives here.

set -euo pipefail

echo "══════════════════════════════════════════════════════════"
echo "  Setting up Arch Linux dev environment..."
echo "══════════════════════════════════════════════════════════"

# ── Update system ────────────────────────────────────────────────
echo "[1/8] Updating system..."
sudo pacman -Syu --noconfirm

# ── Core packages ────────────────────────────────────────────────
echo "[2/8] Installing core packages..."
sudo pacman -S --needed --noconfirm \
    base-devel git curl wget unzip tar \
    openssh openssl zlib \
    man-db man-pages \
    zsh \
    neovim \
    ripgrep fd fzf bat eza zoxide delta bottom \
    lazygit \
    jq yq htop \
    python python-pip python-virtualenv \
    go \
    nodejs npm \
    cmake ninja meson \
    docker-compose kubectl helm \
    github-cli \
    tmux \
    thunar gvfs thunar-archive-plugin \
    virt-manager

# ── Install yay (AUR helper) ────────────────────────────────────
echo "[3/8] Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    echo "[OK] yay installed"
else
    echo "[OK] yay already installed"
fi

# ── AUR packages ─────────────────────────────────────────────────
echo "[4/8] Installing AUR packages..."
yay -S --needed --noconfirm \
    fnm-bin \
    starship-bin \
    pnpm-bin \
    2>/dev/null || echo "[WARN] Some AUR packages may have failed"

# ── Setup Node via fnm ──────────────────────────────────────────
echo "[5/8] Setting up Node.js..."
if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash)"
    fnm install --lts 2>/dev/null || true
    fnm default lts-latest 2>/dev/null || true
    echo "[OK] Node.js $(node --version 2>/dev/null || echo 'pending') ready"
fi

# ── Rust via rustup ──────────────────────────────────────────────
echo "[6/8] Installing Rust..."
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    echo "[OK] Rust $(rustc --version) installed"
else
    echo "[OK] Rust already installed"
fi

# ── Git config ───────────────────────────────────────────────────
echo "[7/8] Configuring git..."
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
git config --global init.defaultBranch main
git config --global pull.rebase true

# ── Shell setup ──────────────────────────────────────────────────
echo "[8/8] Setting up shell..."
if [[ "$SHELL" != *"zsh"* ]]; then
    sudo chsh -s "$(which zsh)" "$(whoami)" 2>/dev/null || \
        sudo usermod -s "$(which zsh)" "$(whoami)" 2>/dev/null || \
        echo "[WARN] Could not change shell automatically"
fi

# ── Export apps to host ──────────────────────────────────────────
echo "[INFO] Exporting apps to host desktop..."
distrobox-export --app neovim 2>/dev/null || true
distrobox-export --app lazygit 2>/dev/null || true
distrobox-export --app htop 2>/dev/null || true
distrobox-export --app thunar 2>/dev/null || true
distrobox-export --app virt-manager 2>/dev/null || true

# ── LazyVim bootstrap ────────────────────────────────────────────
NVIM_CONFIG="$HOME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG/lua" ]]; then
    echo "[INFO] LazyVim config will bootstrap on first nvim launch"
fi

echo ""
echo "══════════════════════════════════════════════════════════"
echo "  ✅ Arch dev environment ready!"
echo ""
echo "  Core:"
echo "    neovim, lazygit, tmux, github-cli"
echo "    ripgrep, fd, fzf, bat, eza, zoxide, delta, bottom"
echo ""
echo "  Languages:"
echo "    Python $(python --version 2>/dev/null | cut -d' ' -f2 || echo '3')"
echo "    Node.js $(node --version 2>/dev/null || echo '(via fnm)')"
echo "    Rust $(rustc --version 2>/dev/null | cut -d' ' -f2 || echo '(via rustup)')"
echo "    Go $(go version 2>/dev/null | cut -d' ' -f3 || echo '')"
echo ""
echo "  Cloud/DevOps:"
echo "    docker-compose, kubectl, helm"
echo ""
echo "  AUR: yay installed for extra packages"
echo ""
echo "  Exported to host: neovim, lazygit, htop"
echo "══════════════════════════════════════════════════════════"
