{ inputs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd"];
  };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/5e9a0b4c-003f-42ed-93d2-f716f3b5438b";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=persist" "compress=zstd"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=log" "compress=zstd"];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=snapshots" "compress=zstd"];
  };

  fileSystems."/home/.snapshots" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=home-snapshots" "compress=zstd"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/226f8c67-a2e0-4c30-bede-9f0d8ff88941";
    fsType = "btrfs";
    options = ["subvol=swap" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0959-0935";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/home/bernard/Backup" = {
    device = "/dev/mapper/cryptstorage";
    fsType = "btrfs";
    options = ["subvol=@backup" "compress=zstd"];
  };

  fileSystems."/home/bernard/Torrents" = {
    device = "/dev/mapper/cryptstorage";
    fsType = "btrfs";
    options = ["subvol=@torrents" "compress=zstd"];
  };

  swapDevices = [{device = "/swap/swapfile";}];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
