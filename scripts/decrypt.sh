#!/usr/bin/env bash

set -euo pipefail

# TODO: This must be able to mount any host by parsing directly the hardware
# configuration
# nix eval "(import ./hosts/hades/hardware-configuration.nix {lib = (import <nixpkgs> {}).lib;}).boot.initrd.luks.devices"

echo ">>> Starting, please expect to enter your cryptsetup password!"

cryptsetup luksOpen /dev/nvme0n1p2 cryptkey
cryptsetup luksOpen --key-file=/dev/mapper/cryptkey /dev/nvme0n1p3 cryptswap
cryptsetup luksOpen --key-file=/dev/mapper/cryptkey /dev/nvme0n1p4 cryptroot
