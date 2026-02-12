# .zprofile — Login shell profile
# This runs once on login (before .zshrc)

# ── Auto-launch Hyprland on TTY1 ─────────────────────────────────
# Zero-click boot: autologin → this script → Hyprland
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
