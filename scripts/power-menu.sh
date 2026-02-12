#!/usr/bin/env bash
# scripts/power-menu.sh — Wofi power menu (alternative to wlogout)
# Keybind: $mainMod SHIFT, Q

set -euo pipefail

entries="  Lock\n  Logout\n  Suspend\n⏻  Shutdown\n  Reboot"

chosen=$(echo -e "$entries" | wofi --show dmenu --prompt "Power" --width 250 --height 280 --cache-file /dev/null)

case "$chosen" in
    *Lock)      hyprlock ;;
    *Logout)    hyprctl dispatch exit ;;
    *Suspend)   systemctl suspend ;;
    *Shutdown)  systemctl poweroff ;;
    *Reboot)    systemctl reboot ;;
esac
