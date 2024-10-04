{ inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../common/hardware/yubihsm.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
