#!/usr/bin/env bash
# helpers.sh — Shared utility functions for the dotfiles installer
# Sourced by install.sh and other setup scripts

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m' # used by consumers
export CYAN
BOLD='\033[1m'
RESET='\033[0m'

# ── Logging ──────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${RESET}    $*"; }
success() { echo -e "${GREEN}[OK]${RESET}      $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}    $*"; }
error()   { echo -e "${RED}[ERROR]${RESET}   $*" >&2; }
fatal()   { error "$*"; exit 1; }

section() {
    echo ""
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${MAGENTA}${BOLD}  $*${RESET}"
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ── Guards ───────────────────────────────────────────────────────────────────
require_cmd() {
    command -v "$1" &>/dev/null || fatal "'$1' is required but not found in PATH"
}

require_not_root() {
    [[ $EUID -ne 0 ]] || fatal "Do not run this script as root. It will use sudo when needed."
}

require_debian() {
    if [[ ! -f /etc/os-release ]]; then
        fatal "Cannot detect OS — /etc/os-release missing"
    fi
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "$ID" != "debian" ]]; then
        fatal "This script is designed for Debian. Detected: $ID"
    fi
    info "Detected Debian $VERSION_CODENAME ($VERSION_ID)"
}

# ── Helpers ──────────────────────────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR

is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii" 2>/dev/null
}

apt_install() {
    local packages=("$@")
    if [[ ${#packages[@]} -eq 0 ]]; then
        warn "apt_install called with no packages"
        return
    fi
    info "Installing ${#packages[@]} package(s)..."
    sudo apt-get install -y --no-install-recommends "${packages[@]}"
}

stow_package() {
    local pkg="$1"
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        warn "Stow package '$pkg' not found, skipping"
        return
    fi
    info "Stowing $pkg → ~/"
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
    success "Stowed $pkg"
}

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup
        backup="${target}.bak.$(date +%s)"
        warn "Backing up existing $target → $backup"
        mv "$target" "$backup"
    fi
}
