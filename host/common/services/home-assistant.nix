{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "apple_tv"
      "brother"
      "default_config"
      "icloud"
      "ipp"
      "jellyfin"
      "met"
      "otbr"
      "ring"
      "radarr"
      "roomba"
      "snmp"
      "sonarr"
      "sonos"
      "unifi"
      "unifiprotect"
      "upnp"
      "webostv"
    ];
    customComponents = [
      (pkgs.buildHomeAssistantComponent rec {
        owner = "hultenvp";
        domain = "solis";
        version = "3.6.0";

        src = pkgs.fetchFromGitHub {
          owner = "hultenvp";
          repo = "solis-sensor";
          rev = "v${version}";
          sha256 = "sha256-DIUhUN1UfyXptaldJBsQEsImEnQqi4zFFKp70yXxDSk=";
        };

        dependencies = [ pkgs.python312Packages.aiofiles ];
      })
      pkgs.touchlinesl
    ];
    config = {
      default_config = { };
    };
  };
}
