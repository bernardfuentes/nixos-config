{ lib, ... }:
{
  imports = [ ../common/services/networkmanager.nix ];
  time.timeZone = lib.mkForce "Europe/Madrid";
}
