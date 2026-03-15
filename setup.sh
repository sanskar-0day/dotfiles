#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# NixOS Dotfiles Bootstrap Script
# Run this on a fresh NixOS minimal install to get everything
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

DOTFILES_REPO="https://github.com/Sanskar-0day/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
FLAKE_NAME="nixos"

echo "══════════════════════════════════════════════"
echo "  NixOS Dotfiles Bootstrap"
echo "══════════════════════════════════════════════"

# 1. Enable flakes (needed on minimal install)
echo "[1/5] Enabling Nix flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# 2. Install git temporarily
echo "[2/5] Installing git..."
nix-env -iA nixos.git 2>/dev/null || true

# 3. Clone dotfiles
if [ -d "$DOTFILES_DIR" ]; then
  echo "[3/5] Dotfiles already exist at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull
else
  echo "[3/5] Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# 4. Copy hardware config from current system
echo "[4/5] Copying hardware-configuration.nix from current system..."
if [ -f /etc/nixos/hardware-configuration.nix ]; then
  cp /etc/nixos/hardware-configuration.nix "$DOTFILES_DIR/hosts/nixos/hardware.nix"
  echo "  → Copied! Review the file to make sure it's correct."
else
  echo "  ⚠ No hardware-configuration.nix found!"
  echo "  Run: sudo nixos-generate-config"
  echo "  Then copy /etc/nixos/hardware-configuration.nix to $DOTFILES_DIR/hosts/nixos/hardware.nix"
fi

# 5. Build (boot entry) for safe NVIDIA updates
echo "[5/5] Building boot entry (safe for NVIDIA)..."
echo ""
echo "Ready! Run the following command to build a boot entry:"
echo ""
echo "  sudo nixos-rebuild boot --flake $DOTFILES_DIR#$FLAKE_NAME"
echo ""
echo "Reboot to apply the new generation."
echo "After reboot, run 'home-manager switch --flake $DOTFILES_DIR#sanskar' if needed."
echo "Then run 'gh auth login' to set up GitHub."
echo "══════════════════════════════════════════════"
