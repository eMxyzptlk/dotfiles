{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.luks.devices = {
    cryptkey = {
      device = "/dev/disk/by-uuid/3830842b-a589-45e0-a51d-4ed516472575";
    };

    cryptroot = {
      device = "/dev/disk/by-uuid/ec133595-6294-4756-95ea-3891297f6477";
      keyFile = "/dev/mapper/cryptkey";
    };

    cryptswap = {
      device = "/dev/disk/by-uuid/71aab354-3872-4316-a26c-b4090d73275c";
      keyFile = "/dev/mapper/cryptkey";
    };

    cryptstorage = {
      device = "/dev/disk/by-uuid/d339f141-7544-44d4-89ec-312af0e087cc";
      keyFile = "/dev/mapper/cryptkey";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@nixos/@root" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@nixos/@home" ];
    };

    "/code" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@code" "X-mount.mkdir=0700" ];
    };

    "/private" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@private" "X-mount.mkdir=0700" ];
    };

    "/home/kalbasit/storage" = {
      device = "/dev/disk/by-uuid/d8a3aad7-3fe8-4986-acc5-c6f7525c9af4";
      fsType = "btrfs";
      options = [ "subvol=@home-kalbasit-storage" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F4E5-ABC1";
      fsType = "vfat";
    };

    # Root

    "/mnt/volumes/root" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
    };

    # Storage

    "/mnt/volumes/storage" = {
      device = "/dev/disk/by-uuid/d8a3aad7-3fe8-4986-acc5-c6f7525c9af4";
      fsType = "btrfs";
    };

    # ArchOS

    "/mnt/arch" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@arch/@root" ];
    };

    "/mnt/arch/home" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@arch/@home" ];
    };

    "/mnt/arch/code" = {
      device = "/dev/disk/by-uuid/e2b2367b-f458-4c55-a3f0-87cef3366d62";
      fsType = "btrfs";
      options = [ "subvol=@code" ];
    };

    "/mnt/arch/home/kalbasit/storage" = {
      device = "/dev/disk/by-uuid/d8a3aad7-3fe8-4986-acc5-c6f7525c9af4";
      fsType = "btrfs";
      options = [ "subvol=@home-kalbasit-storage" ];
    };

    "/mnt/arch/boot/efi" = {
      device = "/dev/disk/by-uuid/F4E5-ABC1";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a3e2591f-a1d4-4d75-b09c-094416b485c4"; }
  ];
}
