#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# NixOS Dotfiles Bootstrap Script
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

# Colors for better UX
BRIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DOTFILES_REPO="https://github.com/Sanskar-0day/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
FLAKE_NAME="nixos"

echo -e "${BRIGHT_BLUE}══════════════════════════════════════════════${NC}"
echo -e "${BRIGHT_BLUE}  NixOS Dotfiles Bootstrap Utility${NC}"
echo -e "${BRIGHT_BLUE}══════════════════════════════════════════════${NC}"

# 1. Pre-flight checks
echo -e "\n${YELLOW}[1/6] Pre-flight checks...${NC}"
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Error: This script should NOT be run as root. Root will be requested via sudo when needed.${NC}"
   exit 1
fi

if ! ping -c 1 8.8.8.8 &> /dev/null; then
  echo -e "${RED}Error: No internet connection detected.${NC}"
  exit 1
fi
echo -e "  ${GREEN}✓ Environment ready${NC}"

# 2. Enable flakes (needed on minimal install)
echo -e "\n${YELLOW}[2/6] Enabling Nix flakes...${NC}"
mkdir -p ~/.config/nix
if ! grep -q "flakes" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  echo -e "  ${GREEN}✓ Flakes enabled${NC}"
else
  echo -e "  ${GREEN}✓ Flakes already enabled${NC}"
fi

# 3. Install git temporarily
echo -e "\n${YELLOW}[3/6] Ensuring git is available...${NC}"
if ! command -v git &> /dev/null; then
  nix-env -iA nixos.git
  echo -e "  ${GREEN}✓ Git installed${NC}"
else
  echo -e "  ${GREEN}✓ Git already present${NC}"
fi

# 4. Clone dotfiles
echo -e "\n${YELLOW}[4/6] Synchronizing dotfiles...${NC}"
if [ -d "$DOTFILES_DIR" ]; then
  echo -e "  ${GREEN}✓ Dotfiles already exist at $DOTFILES_DIR, pulling latest...${NC}"
  git -C "$DOTFILES_DIR" pull
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  echo -e "  ${GREEN}✓ Repository cloned${NC}"
fi

# 5. Handle Hardware Configuration
echo -e "\n${YELLOW}[5/6] Configuration check...${NC}"
if [ ! -f "$DOTFILES_DIR/hosts/nixos/hardware.nix" ]; then
  if [ -f /etc/nixos/hardware-configuration.nix ]; then
    cp /etc/nixos/hardware-configuration.nix "$DOTFILES_DIR/hosts/nixos/hardware.nix"
    echo -e "  ${GREEN}✓ Copied hardware-configuration.nix to source${NC}"
  else
    echo -e "  ${RED}⚠ No hardware configuration found! Run 'sudo nixos-generate-config' first.${NC}"
    exit 1
  fi
else
  echo -e "  ${GREEN}✓ Hardware configuration exists${NC}"
fi

# 6. Conclusion & Next Steps
echo -e "\n${YELLOW}[6/6] Bootstrap Complete!${NC}"
echo -e "${BRIGHT_BLUE}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}Ready to deploy your configuration.${NC}"
echo -e "\nRun the following to build your first generation:"
echo -e "  ${BRIGHT_BLUE}sudo nixos-rebuild boot --flake $DOTFILES_DIR#$FLAKE_NAME${NC}"
echo -e "\n${YELLOW}Post-install reminders:${NC}"
echo -e "  1. Reboot to apply kernel and driver changes."
echo -e "  2. Run ${BRIGHT_BLUE}'hms'${NC} (home-manager switch alias) after reboot."
echo -e "  3. Authenticate with GitHub: ${BRIGHT_BLUE}'gh auth login'${NC}"
echo -e "  4. Set up SSH keys: ${BRIGHT_BLUE}'ssh-keygen -t ed25519'${NC}"
echo -e "${BRIGHT_BLUE}══════════════════════════════════════════════${NC}"
