#!/usr/bin/env bash
# Wine wrapper — auto-creates a prefix per-folder and runs any .exe
# Used as the default handler for .exe files in KDE/Dolphin

set -euo pipefail

EXE_PATH="$(realpath "$1")"
EXE_DIR="$(dirname "$EXE_PATH")"
EXE_NAME="$(basename "$EXE_PATH")"

# Create a prefix name from the parent folder
FOLDER_NAME="$(basename "$EXE_DIR" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')"
PREFIX="$HOME/Games/wine-$FOLDER_NAME"

export WINEPREFIX="$PREFIX"
export WINEARCH=win64
export STAGING_SHARED_MEMORY=1
export DXVK_HUD=fps

# Ensure unlimited stack for FitGirl/Oodle decompressors
ulimit -s unlimited 2>/dev/null || true

# Auto-init prefix if new
if [ ! -d "$PREFIX/drive_c" ]; then
  notify-send "🍷 Wine" "Creating new prefix for: $FOLDER_NAME" 2>/dev/null || true
  wineboot --init 2>/dev/null
  wineserver --wait
  # Install essential dependencies
  winetricks -q vcrun2022 dxvk d3dcompiler_47 corefonts 2>/dev/null || true
  notify-send "🍷 Wine" "Prefix ready! Launching $EXE_NAME..." 2>/dev/null || true
fi

# Run the exe
cd "$EXE_DIR"
wine "$EXE_PATH"
