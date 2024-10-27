{ inputs, ... }: 
{
  imports = [
    ./hyprland.nix
    ./config.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./variables.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
