{ pkgs, ... }:
{
  services.udev = {
    packages = [
      pkgs.g810-led
    ];
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", RUN+="${pkgs.g810-led}/bin/g810-led -a 0000ff"
    '';
  };
}