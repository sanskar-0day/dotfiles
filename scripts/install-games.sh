#!/usr/bin/env bash
set -euo pipefail

# ─── Wine Game Installer for FitGirl Repacks ───────────────────
# Creates a dedicated Wine prefix per game with all dependencies.
# Usage: ./install-games.sh

GAMES_DIR="$HOME/Games"
DOWNLOADS="$HOME/Downloads"

# List of games to install (folder name → short name)
declare -A GAMES=(
  ["NieR - Automata [FitGirl Repack]"]="nier-automata"
  ["Resident Evil 4 (2023) [FitGirl Repack]"]="re4"
  ["Sniper Elite 4 [FitGirl Repack]"]="sniper-elite-4"
  ["The Genesis Order [FitGirl Repack]"]="genesis-order"
  ["HoneySelect 2 DX [FitGirl Repack]"]="honeyselect2"
)

setup_prefix() {
  local name="$1"
  local prefix="$GAMES_DIR/$name"

  echo "═══════════════════════════════════════════════"
  echo "  Setting up Wine prefix: $name"
  echo "═══════════════════════════════════════════════"

  export WINEPREFIX="$prefix"
  export WINEARCH=win64

  # Initialize the prefix
  if [ ! -d "$prefix" ]; then
    echo "[1/4] Creating Wine prefix..."
    wineboot --init 2>/dev/null
    wineserver --wait
  else
    echo "[1/4] Prefix already exists, skipping init."
  fi

  # Install dependencies
  echo "[2/4] Installing Visual C++ runtime..."
  winetricks -q vcrun2022 2>/dev/null || true

  echo "[3/4] Installing DirectX & DXVK..."
  winetricks -q dxvk d3dcompiler_47 2>/dev/null || true

  echo "[4/4] Installing core fonts..."
  winetricks -q corefonts 2>/dev/null || true

  echo "✓ Prefix ready: $prefix"
  echo ""
}

install_game() {
  local folder="$1"
  local name="$2"
  local setup="$DOWNLOADS/$folder/setup.exe"

  if [ ! -f "$setup" ]; then
    echo "⚠ Skipping $name — setup.exe not found in '$folder'"
    return
  fi

  export WINEPREFIX="$GAMES_DIR/$name"
  export WINEARCH=win64

  echo "═══════════════════════════════════════════════"
  echo "  Installing: $folder"
  echo "  Prefix: $WINEPREFIX"
  echo "═══════════════════════════════════════════════"
  echo ""
  echo "The installer window will open now."
  echo "Choose your install directory INSIDE the prefix, e.g.:"
  echo "  C:\\Games\\$name"
  echo ""

  wine "$setup"
  wineserver --wait

  echo ""
  echo "✓ Installation complete for $name"
  echo "  To run: WINEPREFIX=$WINEPREFIX wine <game.exe>"
  echo ""
}

# ── Main ───────────────────────────────────────────────────────

echo ""
echo "🎮 Wine Game Installer for NixOS"
echo "================================"
echo ""
echo "This will set up Wine prefixes with DXVK + dependencies"
echo "for each game, then launch the installers one by one."
echo ""

mkdir -p "$GAMES_DIR"

# Menu
echo "Games found:"
i=1
declare -a FOLDERS=()
declare -a NAMES=()
for folder in "${!GAMES[@]}"; do
  name=${GAMES[$folder]}
  if [ -f "$DOWNLOADS/$folder/setup.exe" ]; then
    echo "  $i) $folder"
    FOLDERS+=("$folder")
    NAMES+=("$name")
    ((i++))
  fi
done

echo ""
echo "  a) Install ALL"
echo "  q) Quit"
echo ""
read -rp "Choose [1-${#FOLDERS[@]}/a/q]: " choice

case "$choice" in
  a|A)
    for idx in "${!FOLDERS[@]}"; do
      setup_prefix "${NAMES[$idx]}"
      install_game "${FOLDERS[$idx]}" "${NAMES[$idx]}"
    done
    ;;
  q|Q)
    echo "Bye!"
    exit 0
    ;;
  *)
    idx=$((choice - 1))
    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#FOLDERS[@]}" ]; then
      setup_prefix "${NAMES[$idx]}"
      install_game "${FOLDERS[$idx]}" "${NAMES[$idx]}"
    else
      echo "Invalid choice."
      exit 1
    fi
    ;;
esac

echo ""
echo "🎮 All done! To launch a game later:"
echo "  WINEPREFIX=~/Games/<game-name> wine <path-to-game.exe>"
echo ""
echo "Or use Lutris/Bottles for a GUI experience."
