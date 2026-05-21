#!/bin/bash
set -e
NIXOS_DIR="$(realpath "$(dirname "$0")")"

sudo rm -f /etc/nixos/*.nix /etc/nixos/flake.lock

for f in "$NIXOS_DIR"/*.nix; do
  sudo ln -sf "$f" "/etc/nixos/$(basename "$f")"
done

# Symlink flake.lock if it exists (generated after first `nix flake update`)
if [ -f "$NIXOS_DIR/flake.lock" ]; then
  sudo ln -sf "$NIXOS_DIR/flake.lock" /etc/nixos/flake.lock
fi

echo "Synced. To apply:"
echo "  sudo nixos-rebuild switch --flake /etc/nixos#nixos-aws"
