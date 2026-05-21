{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/amazon-image.nix")
  ];

  # AWS EC2 block device
  fileSystems."/" = {
    device  = "/dev/xvda1";
    fsType  = "ext4";
  };

  fileSystems."/data" = {
  device  = "/dev/disk/by-label/data";
  fsType  = "ext4";
  options = [ "defaults" "nofail" ];  # nofail so boot succeeds if volume absent
};

  # Extra kernel modules for AWS networking and storage
  boot.initrd.availableKernelModules = [
    "xen_blkfront"
    "xen_netfront"
    "nvme"
    "sr_mod"
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "sd_mod"
  ];
  boot.initrd.kernelModules  = [];
  boot.kernelModules         = [];
  boot.extraModulePackages   = [];

  # AWS elastic network adapter
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
}
