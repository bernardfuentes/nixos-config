{ self, pkgs, lib, inputs, ...}: 
{
  # imports = [ inputs.nix-gaming.nixosModules.default ];
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

  };
  nixpkgs = {
    overlays = [
      inputs.nur.overlay
    ];
    config = {
      allowUnfree = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  time.timeZone = "Australia/Adelaide";
  i18n.defaultLocale = "en_AU.UTF-8";
  system.stateVersion = "24.05";
}
