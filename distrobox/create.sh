#!/usr/bin/env bash
# distrobox/create.sh — Create the Arch Linux dev container

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/helpers.sh
source "$SCRIPT_DIR/../scripts/helpers.sh"

CONTAINER_NAME="dev"
IMAGE="docker.io/library/archlinux:latest"

# ── Check if container already exists ────────────────────────────
if distrobox list 2>/dev/null | grep -q "$CONTAINER_NAME"; then
    info "Container '$CONTAINER_NAME' already exists"
    info "To recreate: dots rebuild"
    return 0 2>/dev/null || exit 0
fi

# ── Create the container ─────────────────────────────────────────
info "Creating distrobox container '$CONTAINER_NAME'..."
info "Image: $IMAGE"

distrobox create \
    --name "$CONTAINER_NAME" \
    --image "$IMAGE" \
    --yes

success "Container '$CONTAINER_NAME' created"

# ── Run the dev setup inside the container ───────────────────────
info "Running dev setup inside container (this takes a few minutes)..."
distrobox enter "$CONTAINER_NAME" -- bash -c "$(cat "$SCRIPT_DIR/setup-dev.sh")"

success "Dev container '$CONTAINER_NAME' is ready!"
info "Enter with: dots dev   (or: distrobox enter dev)"
