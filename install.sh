#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  DOTFILES ORCHESTRATOR — Install & Setup Engine
#  Inspired by github.com/dusklinux/dusky ORCHESTRA.sh
# ══════════════════════════════════════════════════════════════════════════════
#  Features:
#    • State tracking — resumes from where it left off
#    • Dry-run mode — preview without executing
#    • Sudo keepalive — no repeated password prompts
#    • Logging — colorized terminal + clean log file
#    • Pre-flight validation — checks all scripts exist
#    • Retry on failure — skip, retry, or quit per-step
#    • Execution timer
#
#  Usage:
#    ./install.sh              # Normal run
#    ./install.sh --dry-run    # Preview execution plan
#    ./install.sh --reset      # Clear state and start fresh
#    ./install.sh --help
# ══════════════════════════════════════════════════════════════════════════════

set -o errexit
set -o nounset
set -o pipefail

# ── Paths ────────────────────────────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR
readonly STATE_FILE="$HOME/.local/state/dotfiles-install-state"
readonly LOG_DIR="$HOME/.local/state/dotfiles-logs"
readonly LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"
readonly SUDO_REFRESH_INTERVAL=50

# ── Install Sequence ─────────────────────────────────────────────────────────
# Format: "MODE | script_path | description"
#   S = sudo (runs as root)
#   U = user  (runs as current user)
INSTALL_SEQUENCE=(
    "S | host/setup.sh          | Host system packages, NVIDIA, autologin, PipeWire"
    "U | flatpak/setup.sh       | Flatpak + Flathub apps (Firefox)"
    "U | STOW                   | Symlink all dotfile configs via stow"
    "S | SYSTEMD                | Install auto-update timer"
    "U | distrobox/create.sh    | Create & provision Arch dev container"
    "U | SHELL                  | Set zsh as default shell"
    "U | FONT_CACHE             | Rebuild font cache"
)

# ── Colors ───────────────────────────────────────────────────────────────────
declare -g RED="" GREEN="" BLUE="" YELLOW="" MAGENTA="" BOLD="" RESET=""

if [[ -t 1 ]] && command -v tput &>/dev/null; then
    if (( $(tput colors 2>/dev/null || echo 0) >= 8 )); then
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
        MAGENTA=$(tput setaf 5)
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
    fi
fi

# ── Logging ──────────────────────────────────────────────────────────────────
log() {
    local level="$1" msg="$2" color=""
    case "$level" in
        INFO)    color="$BLUE"    ;;
        OK)      color="$GREEN"   ;;
        WARN)    color="$YELLOW"  ;;
        ERROR)   color="$RED"     ;;
        RUN)     color="$MAGENTA" ;;
    esac
    printf "%s[%s]%s %s\n" "${color}" "${level}" "${RESET}" "${msg}"
}

section() {
    echo ""
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${MAGENTA}${BOLD}  $*${RESET}"
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

setup_logging() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
    # Tee output to both screen (colored) and log file (stripped)
    exec 3>&1 4>&2
    exec > >(tee >(sed 's/\x1B\[[0-9;]*[a-zA-Z]//g; s/\x1B(B//g' >> "$LOG_FILE")) 2>&1
    echo "--- Installation Started: $(date '+%Y-%m-%d %H:%M:%S') ---"
    echo "--- Log File: $LOG_FILE ---"
}

# ── Sudo Keepalive ───────────────────────────────────────────────────────────
declare -g SUDO_PID=""

init_sudo() {
    log "INFO" "Sudo privileges required. Please authenticate."
    if ! sudo -v; then
        log "ERROR" "Sudo authentication failed."
        exit 1
    fi
    ( while true; do sudo -n true; sleep "$SUDO_REFRESH_INTERVAL"; kill -0 "$$" || exit; done 2>/dev/null ) &
    SUDO_PID=$!
    disown "$SUDO_PID"
}

cleanup() {
    local exit_code=$?
    if [[ -n "${SUDO_PID:-}" ]]; then
        kill "$SUDO_PID" 2>/dev/null || true
    fi
    if [[ $exit_code -eq 0 ]]; then
        log "OK" "Orchestrator finished successfully."
    else
        log "ERROR" "Orchestrator exited with error code $exit_code."
    fi
}
trap cleanup EXIT

# ── Utility ──────────────────────────────────────────────────────────────────
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.bak.$(date +%s)"
        log "WARN" "Backing up $target → $backup"
        mv "$target" "$backup"
    fi
}

stow_package() {
    local pkg="$1"
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        log "WARN" "Stow package '$pkg' not found, skipping"
        return
    fi
    log "INFO" "Stowing $pkg → ~/"
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
    log "OK" "Stowed $pkg"
}

# ── Built-in Step Handlers ───────────────────────────────────────────────────
run_stow() {
    section "Linking Configs via Stow"
    # Backup existing non-symlink configs
    for dir in hypr waybar wofi dunst kitty nvim wlogout starship; do
        backup_if_exists "$HOME/.config/$dir"
    done
    backup_if_exists "$HOME/.zshrc"
    backup_if_exists "$HOME/.zprofile"
    mkdir -p "$HOME/.config"

    # Stow all config packages
    for pkg in hyprland waybar wofi dunst kitty nvim shell wlogout; do
        [[ -d "$DOTFILES_DIR/$pkg" ]] && stow_package "$pkg"
    done
    log "OK" "All configs linked!"
}

run_systemd() {
    section "Systemd Auto-Update Timer"
    sudo cp "$DOTFILES_DIR/systemd/auto-update.service" /etc/systemd/system/
    sudo cp "$DOTFILES_DIR/systemd/auto-update.timer" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now auto-update.timer
    log "OK" "Auto-update timer enabled (daily apt + flatpak)"
}

run_shell_change() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        log "INFO" "Changing default shell to zsh..."
        sudo chsh -s "$(which zsh)" "$(whoami)"
        log "OK" "Default shell changed to zsh"
    else
        log "OK" "Shell is already zsh"
    fi
}

run_font_cache() {
    log "INFO" "Rebuilding font cache..."
    fc-cache -fv &>/dev/null || true
    log "OK" "Font cache rebuilt"
}

# ── Execute a Single Step ────────────────────────────────────────────────────
execute_step() {
    local mode="$1" script="$2" desc="$3" index="$4" total="$5"

    section "[${index}/${total}] $desc"

    case "$script" in
        STOW)       run_stow; return 0 ;;
        SYSTEMD)    run_systemd; return 0 ;;
        SHELL)      run_shell_change; return 0 ;;
        FONT_CACHE) run_font_cache; return 0 ;;
    esac

    # External script
    local script_path="$DOTFILES_DIR/$script"
    if [[ ! -f "$script_path" ]]; then
        log "ERROR" "Script not found: $script_path"
        return 1
    fi

    if [[ "$mode" == "S" ]]; then
        sudo bash "$script_path"
    else
        bash "$script_path"
    fi
}

# ── CLI ──────────────────────────────────────────────────────────────────────
show_help() {
    cat << EOF
${BOLD}Dotfiles Orchestrator${RESET} — Debian 13 + Hyprland + Distrobox

${BOLD}Usage:${RESET}
    ./install.sh              Normal run (resume-aware)
    ./install.sh --dry-run    Preview execution plan
    ./install.sh --reset      Clear state, start fresh
    ./install.sh --help       Show this help

${BOLD}Features:${RESET}
    • Resumes from last successful step if interrupted
    • Logs to $LOG_DIR/
    • Sudo keepalive (no repeated prompts)
    • Retry/skip on failure
EOF
    exit 0
}

dry_run() {
    echo -e "\n${YELLOW}=== DRY RUN ===${RESET}"
    echo -e "State file: ${BOLD}${STATE_FILE}${RESET}\n"
    echo "Execution plan:"
    echo ""

    local i=0
    for entry in "${INSTALL_SEQUENCE[@]}"; do
        ((++i))
        local mode desc script
        IFS='|' read -r mode script desc <<< "$entry"
        mode=$(trim "$mode")
        script=$(trim "$script")
        desc=$(trim "$desc")

        local status_label
        if [[ -f "$STATE_FILE" ]] && grep -Fxq "$script" "$STATE_FILE" 2>/dev/null; then
            status_label="${GREEN}[DONE]${RESET}"
        else
            status_label="${BLUE}[PENDING]${RESET}"
        fi

        printf "  %2d. [%s] %-28s %s  %s\n" "$i" "$mode" "$script" "$status_label" "$desc"
    done
    echo -e "\nNo changes were made."
    exit 0
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    # Root guard
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}ERROR: Do not run as root! Sudo is used internally.${RESET}"
        exit 1
    fi

    # Argument handling
    case "${1:-}" in
        --help|-h)   show_help ;;
        --dry-run|-d) dry_run ;;
        --reset)
            rm -f "$STATE_FILE"
            echo "State reset. Run ./install.sh to start fresh."
            exit 0
            ;;
    esac

    setup_logging

    # OS check
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        log "INFO" "Detected: $PRETTY_NAME"
    fi

    # Timer
    local start_ts=$SECONDS

    # Sudo
    init_sudo

    # State file
    mkdir -p "$(dirname "$STATE_FILE")"
    touch "$STATE_FILE"

    # Session recovery
    if [[ -s "$STATE_FILE" ]]; then
        echo -e "\n${YELLOW}>>> Previous session detected <<<${RESET}"
        read -r -p "  [C]ontinue where you left off, or [S]tart over? [C/s]: " _choice
        if [[ "${_choice,,}" == "s" ]]; then
            rm -f "$STATE_FILE"
            touch "$STATE_FILE"
            log "INFO" "State reset. Starting fresh."
        else
            log "INFO" "Continuing from previous session."
        fi
    fi

    section "Dotfiles Orchestrator"
    log "INFO" "Dotfiles: $DOTFILES_DIR"
    log "INFO" "User: $(whoami)"

    local total=${#INSTALL_SEQUENCE[@]}
    local current=0
    local SKIPPED=()

    for entry in "${INSTALL_SEQUENCE[@]}"; do
        ((++current))

        local mode desc script
        IFS='|' read -r mode script desc <<< "$entry"
        mode=$(trim "$mode")
        script=$(trim "$script")
        desc=$(trim "$desc")

        # Skip if already completed
        if grep -Fxq "$script" "$STATE_FILE" 2>/dev/null; then
            log "WARN" "[${current}/${total}] Skipping: $desc (already completed)"
            continue
        fi

        # Execute with retry loop
        while true; do
            log "RUN" "[${current}/${total}] $desc"

            local result=0
            execute_step "$mode" "$script" "$desc" "$current" "$total" || result=$?

            if [[ $result -eq 0 ]]; then
                echo "$script" >> "$STATE_FILE"
                log "OK" "Finished: $desc"
                break
            else
                log "ERROR" "Failed: $desc (exit code $result)"
                echo -e "${YELLOW}Action:${RESET} [S]kip, [R]etry, or [Q]uit? "
                read -r -p "  Choice (s/r/q): " _fail
                case "${_fail,,}" in
                    s|skip)
                        log "WARN" "Skipping: $desc"
                        SKIPPED+=("$desc")
                        break ;;
                    r|retry)
                        log "INFO" "Retrying..."
                        continue ;;
                    *)
                        log "ERROR" "Aborting."
                        exit 1 ;;
                esac
            fi
        done
    done

    # Skipped summary
    if [[ ${#SKIPPED[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}════════════════════════════════════════════════════${RESET}"
        echo -e "${YELLOW}  Skipped steps:${RESET}"
        for s in "${SKIPPED[@]}"; do echo "    • $s"; done
        echo -e "${YELLOW}════════════════════════════════════════════════════${RESET}\n"
    fi

    # Timer
    local duration=$(( SECONDS - start_ts ))
    local minutes=$(( duration / 60 ))
    local seconds=$(( duration % 60 ))

    # Done
    echo -e "\n${GREEN}${BOLD}════════════════════════════════════════════════════${RESET}"
    echo -e "${GREEN}${BOLD}  ✅ Setup Complete!  (${minutes}m ${seconds}s)${RESET}"
    echo ""
    echo -e "  ${BOLD}Quick reference:${RESET}"
    echo "    Super + Q         →  Terminal"
    echo "    Super + D         →  App Launcher"
    echo "    Super + E         →  File Manager"
    echo "    Super + B         →  Browser"
    echo "    Super + V         →  Smart Float"
    echo "    Super + Z         →  Scratchpad"
    echo "    Super + Shift + L →  Lock Screen"
    echo "    dots dev          →  Enter dev container"
    echo ""
    echo -e "  ${BOLD}Reboot to start Hyprland:${RESET} sudo reboot"
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════${RESET}\n"
}

main "$@"
