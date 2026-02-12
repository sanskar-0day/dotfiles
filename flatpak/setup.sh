#!/usr/bin/env bash
# flatpak/setup.sh — Install Flatpak apps from Flathub

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/helpers.sh
source "$SCRIPT_DIR/../scripts/helpers.sh"

# ── Add Flathub remote ───────────────────────────────────────────────────────
if ! flatpak remote-list | grep -q flathub; then
    info "Adding Flathub remote..."
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    success "Flathub added"
else
    success "Flathub already configured"
fi

# ── Install apps ─────────────────────────────────────────────────────────────
while IFS= read -r app; do
    # Skip comments and blank lines
    [[ "$app" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${app// }" ]] && continue

    if flatpak info "$app" &>/dev/null; then
        success "$app already installed"
    else
        info "Installing $app..."
        sudo flatpak install -y flathub "$app"
        success "$app installed"
    fi
done < "$SCRIPT_DIR/apps.txt"

success "All Flatpak apps installed!"
