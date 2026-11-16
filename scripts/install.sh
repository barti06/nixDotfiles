#!/usr/bin/env bash

# set errexit nounset and pipefail
set -euo pipefail

# IMPORTANT: this script considers that you mounted nix on /mnt

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIRECTORY="$(cd "$SCRIPT_DIR/.." && pwd)"
HOST_NAME="${1:-kusabimaru}"
HARDWARE_FILE="$NIX_DIRECTORY/modules/hosts/my-machine/hardware.nix"

if [[ $EUID -ne 0 ]]; then
  echo "elevating privileges..."
  exec sudo "$0" "$@"
fi

# check correct mount points for / and /boot
if ! mountpoint -q /mnt; then
  echo "!! error: /mnt is not mounted!"
  echo "   mount your root partition to /mnt first (e.g. mount /dev/nvme0n1p2 /mnt)"
  exit 1
fi

if ! mountpoint -q /mnt/boot; then
  echo "!! error: /mnt/boot is not mounted!"
  echo "   mount your EFI boot partition to /mnt/boot first (e.g. mount /dev/nvme0n1p1 /mnt/boot)"
  exit 1
fi

# generate HW config
echo "generating hardware config from /mnt..."
nixos-generate-config --root /mnt --show-hardware-config > "$HARDWARE_FILE"
echo "hardware config created in $HARDWARE_FILE!"

# add the file to git
echo "adding the hardware file to git..."
git config --global --add safe.directory "$NIX_DIRECTORY" 2>/dev/null || true
git -C "$NIX_DIRECTORY" add -f "$HARDWARE_FILE"
echo "added the hardware file to git!"

# perform the install
echo "installing nixos for $HOST_NAME..."
nixos-install --root /mnt --flake "$NIX_DIRECTORY#$HOST_NAME"
echo "nix install successful!"
echo "reboot your system to boot to your new nixos!"
