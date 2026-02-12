#!/usr/bin/env bash
# dots — Dotfiles management CLI
# Sourced into Zsh as a function via .zshrc

# shellcheck shell=bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

dots() {
    local cmd="${1:-help}"
    shift 2>/dev/null || true

    case "$cmd" in
        # ── Full Setup ───────────────────────────────────────────────
        setup)
            echo -e "\033[1;35m━━━ dots setup: Full system setup ━━━\033[0m"
            bash "$DOTFILES_DIR/install.sh"
            ;;

        # ── Update Everything ────────────────────────────────────────
        update)
            echo -e "\033[1;35m━━━ dots update ━━━\033[0m"

            # 1. Pull latest dotfiles
            echo -e "\033[0;34m[1/5]\033[0m Pulling dotfiles..."
            git -C "$DOTFILES_DIR" pull --rebase 2>/dev/null || \
                echo -e "\033[1;33m[WARN]\033[0m Git pull failed (offline or no remote)"

            # 2. Re-stow all configs
            echo -e "\033[0;34m[2/5]\033[0m Re-linking configs..."
            dots sync

            # 3. System update
            echo -e "\033[0;34m[3/5]\033[0m Updating system packages..."
            sudo apt-get update -qq && sudo apt-get upgrade -y -qq

            # 4. Flatpak update
            echo -e "\033[0;34m[4/5]\033[0m Updating Flatpak apps..."
            flatpak update -y 2>/dev/null

            # 5. Distrobox update
            echo -e "\033[0;34m[5/5]\033[0m Updating distrobox container..."
            distrobox enter dev -- sudo pacman -Syu --noconfirm 2>/dev/null || \
                echo -e "\033[1;33m[WARN]\033[0m Container update skipped (not running?)"

            echo -e "\033[0;32m[OK]\033[0m Everything up to date!"
            ;;

        # ── Sync (re-stow) ──────────────────────────────────────────
        sync)
            echo -e "\033[0;34m[INFO]\033[0m Re-stowing all configs..."
            local packages=(hyprland waybar wofi dunst kitty nvim shell wlogout)
            for pkg in "${packages[@]}"; do
                if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
                    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg" 2>/dev/null && \
                        echo -e "\033[0;32m  ✓\033[0m $pkg" || \
                        echo -e "\033[0;31m  ✗\033[0m $pkg (conflict?)"
                fi
            done
            echo -e "\033[0;32m[OK]\033[0m Configs synced"
            ;;

        # ── Edit dotfiles ────────────────────────────────────────────
        edit)
            local target="${1:-}"
            case "$target" in
                hypr|hyprland) ${EDITOR:-nvim} "$DOTFILES_DIR/hyprland/.config/hypr/hyprland.conf" ;;
                bar|waybar)    ${EDITOR:-nvim} "$DOTFILES_DIR/waybar/.config/waybar/config.jsonc" ;;
                kitty)         ${EDITOR:-nvim} "$DOTFILES_DIR/kitty/.config/kitty/kitty.conf" ;;
                zsh|shell)     ${EDITOR:-nvim} "$DOTFILES_DIR/shell/.zshrc" ;;
                nvim|neovim)   ${EDITOR:-nvim} "$DOTFILES_DIR/nvim/.config/nvim/init.lua" ;;
                alias*)        ${EDITOR:-nvim} "$DOTFILES_DIR/shell/aliases.sh" ;;
                star*)         ${EDITOR:-nvim} "$DOTFILES_DIR/shell/.config/starship.toml" ;;
                *)             ${EDITOR:-nvim} "$DOTFILES_DIR" ;;
            esac
            ;;

        # ── Status ───────────────────────────────────────────────────
        status)
            echo -e "\033[1;35m━━━ dots status ━━━\033[0m"
            echo ""

            # Git status
            echo -e "\033[1m📦 Dotfiles repo:\033[0m"
            git -C "$DOTFILES_DIR" status -sb 2>/dev/null || echo "  Not a git repo"
            echo ""

            # Distrobox
            echo -e "\033[1m📦 Distrobox containers:\033[0m"
            distrobox list 2>/dev/null || echo "  distrobox not installed"
            echo ""

            # Flatpak
            echo -e "\033[1m📦 Flatpak apps:\033[0m"
            flatpak list --app --columns=name,version 2>/dev/null || echo "  flatpak not installed"
            echo ""

            # Auto-update timer
            echo -e "\033[1m⏱️  Auto-update timer:\033[0m"
            systemctl is-active auto-update.timer 2>/dev/null || echo "  not active"
            echo ""

            # Stow links
            echo -e "\033[1m🔗 Stow links:\033[0m"
            local packages=(hyprland waybar wofi dunst kitty nvim shell wlogout)
            for pkg in "${packages[@]}"; do
                if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
                    echo -e "  \033[0;32m✓\033[0m $pkg"
                else
                    echo -e "  \033[0;31m✗\033[0m $pkg (missing)"
                fi
            done
            ;;

        # ── Distrobox management ─────────────────────────────────────
        dev)
            distrobox enter dev
            ;;

        rebuild)
            echo -e "\033[0;34m[INFO]\033[0m Rebuilding dev container..."
            distrobox stop dev 2>/dev/null
            distrobox rm -f dev 2>/dev/null
            bash "$DOTFILES_DIR/distrobox/create.sh"
            ;;

        export)
            local app="${1:-}"
            if [[ -z "$app" ]]; then
                echo "Usage: dots export <app-name>"
                echo "Exports an app from the dev container to the host desktop."
                echo "Example: dots export neovim"
                return 1
            fi
            distrobox enter dev -- distrobox-export --app "$app"
            ;;

        # ── Commit & push changes ────────────────────────────────────
        save)
            local msg="${1:-update dotfiles}"
            git -C "$DOTFILES_DIR" add -A
            git -C "$DOTFILES_DIR" commit -m "$msg"
            git -C "$DOTFILES_DIR" push
            echo -e "\033[0;32m[OK]\033[0m Dotfiles saved and pushed"
            ;;

        # ── Reload shell ─────────────────────────────────────────────
        reload)
            echo -e "\033[0;34m[INFO]\033[0m Reloading shell..."
            exec zsh
            ;;

        # ── Help ─────────────────────────────────────────────────────
        help|*)
            echo ""
            echo -e "\033[1;35m  dots\033[0m — Dotfiles management CLI"
            echo ""
            echo -e "\033[1m  SETUP & UPDATE\033[0m"
            echo "    dots setup          Full system setup (first-time install)"
            echo "    dots update         Pull dotfiles + update system + flatpak + container"
            echo "    dots sync           Re-stow all configs (no package changes)"
            echo "    dots save [msg]     Git add, commit, push dotfiles"
            echo ""
            echo -e "\033[1m  EDIT CONFIGS\033[0m"
            echo "    dots edit           Open dotfiles dir in editor"
            echo "    dots edit hypr      Edit Hyprland config"
            echo "    dots edit waybar    Edit Waybar config"
            echo "    dots edit kitty     Edit Kitty config"
            echo "    dots edit zsh       Edit .zshrc"
            echo "    dots edit nvim      Edit Neovim config"
            echo "    dots edit alias     Edit shell aliases"
            echo "    dots edit starship  Edit Starship prompt"
            echo ""
            echo -e "\033[1m  DISTROBOX\033[0m"
            echo "    dots dev            Enter dev container"
            echo "    dots rebuild        Destroy and recreate dev container"
            echo "    dots export <app>   Export app from container to host"
            echo ""
            echo -e "\033[1m  OTHER\033[0m"
            echo "    dots status         Show system status overview"
            echo "    dots reload         Reload Zsh"
            echo "    dots help           Show this help"
            echo ""
            ;;
    esac
}
