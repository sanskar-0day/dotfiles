#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#  Clipboard Manager — cliphist + wofi/fzf with image preview & pinning
#  Inspired by dusky's terminal_clipboard.sh
# ═══════════════════════════════════════════════════════════════════════════════
#  Dependencies: cliphist, wl-clipboard, wofi OR fzf
#  Optional: chafa (image preview in terminal), swappy (annotation)
#
#  Features:
#    • Text and image clipboard history
#    • Pin/unpin entries (persistent favorites)
#    • Delete individual entries or wipe all
#    • Works in both Wofi (graphical) and FZF (terminal) mode
#
#  Usage:
#    clipboard.sh             # Wofi mode (graphical popup)
#    clipboard.sh --fzf       # FZF mode (inline terminal)
#    clipboard.sh --wipe      # Clear all history
# ═══════════════════════════════════════════════════════════════════════════════

set -o nounset
set -o pipefail

# ── Config ───────────────────────────────────────────────────────────────────
readonly XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly PINS_DIR="$XDG_DATA_HOME/clipboard-pins"
readonly CACHE_DIR="$XDG_CACHE_HOME/clipboard-images"
readonly ICON_PIN="📌"
readonly ICON_IMG="📸"

# ── Setup ────────────────────────────────────────────────────────────────────
check_deps() {
    local missing=()
    for cmd in cliphist wl-copy; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if ((${#missing[@]})); then
        notify-send -u critical "Clipboard" "Missing: ${missing[*]}" 2>/dev/null
        exit 1
    fi
    mkdir -p "$PINS_DIR" "$CACHE_DIR" 2>/dev/null
    chmod 700 "$PINS_DIR" "$CACHE_DIR" 2>/dev/null
}

# ── Notifications ────────────────────────────────────────────────────────────
notify() {
    notify-send -a "Clipboard" "📋 Clipboard" "$1" 2>/dev/null || true
}

# ── Generate list ────────────────────────────────────────────────────────────
generate_list() {
    # Pinned items first
    if [[ -d "$PINS_DIR" ]]; then
        local pin
        while IFS= read -r pin; do
            [[ -r "$pin" ]] || continue
            local content
            content=$(<"$pin")
            local preview="${content//$'\n'/ }"
            if ((${#preview} > 60)); then preview="${preview:0:60}…"; fi
            echo "$ICON_PIN $preview"
        done < <(find "$PINS_DIR" -maxdepth 1 -name '*.pin' -type f -printf '%T@\t%p\n' 2>/dev/null | sort -rn | cut -f2)
    fi

    # History items
    cliphist list 2>/dev/null | while IFS=$'\t' read -r id content; do
        if [[ "$content" == *"binary data"* ]]; then
            echo "$ICON_IMG Image [$id]"
        else
            local preview="${content//$'\n'/ }"
            if ((${#preview} > 60)); then preview="${preview:0:60}…"; fi
            echo "$preview"
        fi
    done
}

# ── Copy selected item ───────────────────────────────────────────────────────
do_copy() {
    local selection="$1"
    [[ -z "$selection" ]] && return

    # Handle pinned items
    if [[ "$selection" == "$ICON_PIN "* ]]; then
        local text="${selection#"$ICON_PIN "}"
        # Find matching pin file
        local pin
        for pin in "$PINS_DIR"/*.pin; do
            [[ -f "$pin" ]] || continue
            if [[ "$(<"$pin")" == "$text"* ]]; then
                wl-copy < "$pin"
                notify "Pasted from pin"
                return
            fi
        done
        return
    fi

    # Handle image items
    if [[ "$selection" == "$ICON_IMG "* ]]; then
        local id
        id=$(echo "$selection" | grep -oP '\[\K[0-9]+')
        if [[ -n "$id" ]]; then
            printf '%s\t\n' "$id" | cliphist decode 2>/dev/null | wl-copy --type "image/png"
            notify "Image copied"
        fi
        return
    fi

    # Regular text — find in cliphist by content match
    local line
    line=$(cliphist list 2>/dev/null | grep -F "$selection" | head -1)
    if [[ -n "$line" ]]; then
        echo "$line" | cliphist decode 2>/dev/null | wl-copy
        notify "Copied to clipboard"
    fi
}

# ── Pin toggle ────────────────────────────────────────────────────────────────
do_pin() {
    local selection="$1"
    [[ -z "$selection" ]] && return

    # If already pinned, unpin
    if [[ "$selection" == "$ICON_PIN "* ]]; then
        local text="${selection#"$ICON_PIN "}"
        local pin
        for pin in "$PINS_DIR"/*.pin; do
            [[ -f "$pin" ]] || continue
            if [[ "$(<"$pin")" == "$text"* ]]; then
                rm -f "$pin"
                notify "Unpinned"
                return
            fi
        done
        return
    fi

    # Pin the selected text
    local hash
    hash=$(printf '%s' "$selection" | md5sum | cut -c1-16)
    local pin_file="$PINS_DIR/${hash}.pin"

    # Get full content from cliphist
    local line
    line=$(cliphist list 2>/dev/null | grep -F "$selection" | head -1)
    if [[ -n "$line" ]]; then
        echo "$line" | cliphist decode 2>/dev/null > "$pin_file"
        notify "Pinned!"
    fi
}

# ── Delete entry ─────────────────────────────────────────────────────────────
do_delete() {
    local selection="$1"
    [[ -z "$selection" ]] && return

    if [[ "$selection" == "$ICON_PIN "* ]]; then
        local text="${selection#"$ICON_PIN "}"
        local pin
        for pin in "$PINS_DIR"/*.pin; do
            [[ -f "$pin" ]] || continue
            if [[ "$(<"$pin")" == "$text"* ]]; then
                rm -f "$pin"
                notify "Pin deleted"
                return
            fi
        done
        return
    fi

    local line
    line=$(cliphist list 2>/dev/null | grep -F "$selection" | head -1)
    if [[ -n "$line" ]]; then
        echo "$line" | cliphist delete 2>/dev/null
        notify "Entry deleted"
    fi
}

# ── Wipe all ─────────────────────────────────────────────────────────────────
do_wipe() {
    cliphist wipe 2>/dev/null
    rm -f "$CACHE_DIR"/*.png 2>/dev/null
    notify "Clipboard history cleared"
}

# ── Wofi Mode (graphical popup) ──────────────────────────────────────────────
mode_wofi() {
    local selection
    selection=$(generate_list | wofi \
        --show dmenu \
        --prompt "📋 Clipboard" \
        --width 600 \
        --height 400 \
        --cache-file /dev/null \
        --insensitive \
    ) || return

    do_copy "$selection"
}

# ── FZF Mode (terminal, richer preview) ──────────────────────────────────────
mode_fzf() {
    local self
    self=$(realpath "${BASH_SOURCE[0]}")

    local selection
    selection=$(generate_list | fzf \
        --ansi --reverse --no-sort --exact --no-multi --cycle \
        --border=rounded --border-label=" 📋 Clipboard " --border-label-pos=3 \
        --info=hidden \
        --header="Enter=Copy  Alt-p=Pin  Alt-d=Delete  Alt-w=Wipe" \
        --header-first \
        --prompt="  " --pointer="▌" \
        --bind="alt-p:execute-silent(echo {} | xargs -I{} '$self' --pin-entry '{}')+reload('$self' --list)" \
        --bind="alt-d:execute-silent(echo {} | xargs -I{} '$self' --delete-entry '{}')+reload('$self' --list)" \
        --bind="alt-w:execute-silent('$self' --wipe)+reload('$self' --list)" \
    ) || return

    do_copy "$selection"
}

# ── Entry Point ──────────────────────────────────────────────────────────────
main() {
    check_deps

    case "${1:-}" in
        --fzf)         mode_fzf ;;
        --list)        generate_list ;;
        --pin-entry)   shift; do_pin "$1" ;;
        --delete-entry) shift; do_delete "$1" ;;
        --wipe)        do_wipe ;;
        --help|-h)
            echo "Usage: clipboard.sh [--fzf|--wipe|--help]"
            echo "  (no args)    Wofi popup mode"
            echo "  --fzf        Terminal FZF mode"
            echo "  --wipe       Clear all clipboard history"
            ;;
        *)             mode_wofi ;;
    esac
}

main "$@"
