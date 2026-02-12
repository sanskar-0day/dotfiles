#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#  Screenshot Manager — grim + slurp + swappy
#  Inspired by dusky's grimblast.sh with anti-spam lock
# ═══════════════════════════════════════════════════════════════════════════════
#  Modes:
#    screenshot.sh area        Select a region → clipboard
#    screenshot.sh area-edit   Select a region → open in Swappy for annotation
#    screenshot.sh screen      Full screen → clipboard
#    screenshot.sh screen-edit Full screen → open in Swappy
#    screenshot.sh window      Active window → clipboard
#    screenshot.sh menu        Wofi menu with all options
#
#  Dependencies: grim, slurp, wl-copy
#  Optional: swappy (annotation editor), jq (window capture)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────────────
readonly SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
readonly LOCK_FILE="/tmp/screenshot-lock"

# ── Anti-Spam Lock ───────────────────────────────────────────────────────────
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    exit 1  # Another screenshot in progress
fi

# ── Setup ────────────────────────────────────────────────────────────────────
mkdir -p "$SCREENSHOT_DIR"

timestamp() { date +"%Y-%m-%d_%H-%M-%S"; }
notify() { notify-send -a "Screenshot" "📸 Screenshot" "$1" -i "$2" 2>/dev/null || true; }

# ── Capture Functions ────────────────────────────────────────────────────────
capture_area() {
    local geometry
    geometry=$(slurp -d -b "1e1e2e80" -c "89b4fa" -s "89b4fa20" -w 2 2>/dev/null) || return 1
    local file="$SCREENSHOT_DIR/$(timestamp).png"
    grim -g "$geometry" "$file" 200>&-
    echo "$file"
}

capture_screen() {
    local file="$SCREENSHOT_DIR/$(timestamp).png"
    grim "$file" 200>&-
    echo "$file"
}

capture_window() {
    if ! command -v jq &>/dev/null; then
        # Fallback to area select
        capture_area
        return
    fi
    local geometry
    geometry=$(hyprctl activewindow -j 2>/dev/null | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null) || {
        capture_area
        return
    }
    local file="$SCREENSHOT_DIR/$(timestamp).png"
    grim -g "$geometry" "$file" 200>&-
    echo "$file"
}

# ── Actions ──────────────────────────────────────────────────────────────────
to_clipboard() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    wl-copy < "$file"
    notify "Copied to clipboard" "$file"
    sleep 0.2
}

to_editor() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    sleep 0.2
    flock -u 200  # Release lock before opening editor
    if command -v swappy &>/dev/null; then
        swappy -f "$file" &
    else
        wl-copy < "$file"
        notify "Copied (install swappy for editing)" "$file"
    fi
}

to_clipboard_and_save() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    wl-copy < "$file"
    notify "Saved & copied" "$file"
    sleep 0.2
}

# ── Wofi Menu ────────────────────────────────────────────────────────────────
show_menu() {
    local entries="  Area → Clipboard
  Area → Edit (Swappy)
  Fullscreen → Clipboard
  Fullscreen → Edit
  Window → Clipboard
  Window → Edit"

    local chosen
    chosen=$(echo -e "$entries" | wofi \
        --show dmenu \
        --prompt "📸 Screenshot" \
        --width 350 \
        --height 320 \
        --cache-file /dev/null \
    ) || exit 0

    case "$chosen" in
        *"Area → Clipboard"*)     do_area ;;
        *"Area → Edit"*)          do_area_edit ;;
        *"Fullscreen → Clipboard"*) do_screen ;;
        *"Fullscreen → Edit"*)    do_screen_edit ;;
        *"Window → Clipboard"*)   do_window ;;
        *"Window → Edit"*)        do_window_edit ;;
    esac
}

# ── Mode Handlers ────────────────────────────────────────────────────────────
do_area() {
    local file
    file=$(capture_area) || exit 0
    to_clipboard "$file"
}

do_area_edit() {
    local file
    file=$(capture_area) || exit 0
    to_editor "$file"
}

do_screen() {
    local file
    file=$(capture_screen) || exit 0
    to_clipboard_and_save "$file"
}

do_screen_edit() {
    local file
    file=$(capture_screen) || exit 0
    to_editor "$file"
}

do_window() {
    local file
    file=$(capture_window) || exit 0
    to_clipboard "$file"
}

do_window_edit() {
    local file
    file=$(capture_window) || exit 0
    to_editor "$file"
}

# ── Entry Point ──────────────────────────────────────────────────────────────
case "${1:-menu}" in
    area)        do_area ;;
    area-edit)   do_area_edit ;;
    screen)      do_screen ;;
    screen-edit) do_screen_edit ;;
    window)      do_window ;;
    window-edit) do_window_edit ;;
    menu)        show_menu ;;
    *)
        echo "Usage: screenshot.sh [area|area-edit|screen|screen-edit|window|window-edit|menu]"
        exit 1
        ;;
esac
