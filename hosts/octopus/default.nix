{ pkgs, ... }: 
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  powerManagement.cpuFreqGovernor = "performance";

  environment.etc.crypttab.text = ''
    cryptstorage UUID=1b3b5fcc-a883-4af5-a975-7226ef554a82 /home/bernard/luks/luks-1b3b5fcc-a883-4af5-a975-7226ef554a82.key
  '';
}