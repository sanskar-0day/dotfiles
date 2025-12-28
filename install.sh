#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up dotfiles...${NC}"

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create symlink safely
link_file() {
    local src="$1"
    local dest="$2"
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    # Backup existing file if it exists and is not a symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo -e "${BLUE}Backing up existing file: $dest${NC}"
        mv "$dest" "$dest.backup"
    fi
    
    # Remove existing symlink
    [ -L "$dest" ] && rm "$dest"
    
    # Create new symlink
    ln -sf "$src" "$dest"
    echo -e "${GREEN}✓ Linked: $src -> $dest${NC}"
}

# Install dependencies (optional - uncomment what you need)
echo -e "${BLUE}Installing dependencies...${NC}"
sudo apt update
# sudo apt install -y i3 i3status dmenu feh picom # Uncomment for i3
# sudo apt install -y emacs ripgrep fd-find # Uncomment for Doom

# Doom Emacs
if [ -d "$DOTFILES_DIR/doom" ]; then
    echo -e "${BLUE}Setting up Doom Emacs config...${NC}"
    link_file "$DOTFILES_DIR/doom" "$HOME/.config/doom"
    
    # Install Doom if not present
    if [ ! -d "$HOME/.emacs.d" ]; then
        echo -e "${BLUE}Installing Doom Emacs...${NC}"
        git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
        ~/.emacs.d/bin/doom install
    else
        echo -e "${GREEN}Doom already installed, syncing...${NC}"
        ~/.emacs.d/bin/doom sync
    fi
fi

# i3 window manager
if [ -d "$DOTFILES_DIR/i3" ]; then
    echo -e "${BLUE}Setting up i3 config...${NC}"
    link_file "$DOTFILES_DIR/i3/config" "$HOME/.config/i3/config"
    link_file "$DOTFILES_DIR/i3/i3status.conf" "$HOME/.config/i3status/config"
fi

# Bash
if [ -d "$DOTFILES_DIR/bash" ]; then
    echo -e "${BLUE}Setting up bash config...${NC}"
    link_file "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    [ -f "$DOTFILES_DIR/bash/.bash_aliases" ] && link_file "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
fi

# Git
if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
    echo -e "${BLUE}Setting up git config...${NC}"
    link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
fi

# Setup secrets
if [ -f "$DOTFILES_DIR/secrets.example" ] && [ ! -f "$HOME/.secrets" ]; then
    echo -e "${BLUE}Creating secrets file from template...${NC}"
    cp "$DOTFILES_DIR/secrets.example" "$HOME/.secrets"
    chmod 600 "$HOME/.secrets"
    echo -e "${RED}⚠ Please edit ~/.secrets with your actual secrets${NC}"
fi

echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
echo -e "${BLUE}Reload your shell: source ~/.bashrc${NC}"