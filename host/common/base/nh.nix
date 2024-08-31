{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh;
    flake = "/home/bernard/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since 10d --keep 3";
    };
  };
}
