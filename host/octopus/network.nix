{ pkgs, lib, ... }:
{
  networking = {
    hostName = "octopus";
    networkmanager.enable = true;
    interfaces.enp7s0 = {
      ipv4.addresses = [{
      address = "192.168.1.3";
      prefixLength = 24;
      }];
    };
    defaultGateway = {
        address = "192.168.1.1";
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 16999 59010 59011 ];
      allowedUDPPorts = [ 16999 59010 59011 ];
      # allowedUDPPortRanges = [
        # { from = 4000; to = 4007; }
        # { from = 8000; to = 8010; }
      # ];
    };
  };
}