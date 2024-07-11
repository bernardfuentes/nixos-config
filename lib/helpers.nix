{
  self,
  inputs,
  outputs,
  stateVersion,
  username,
  ...
}:
{
  # Helper function for generating home-manager configs
  mkHome =
    {
      hostname,
      user ? username,
      desktop ? null,
      system ? "x86_64-linux",
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.unstable.legacyPackages.${system};
      extraSpecialArgs = {
        inherit
          self
          inputs
          outputs
          stateVersion
          hostname
          desktop
          ;
        username = user;
      };
      modules = [
        inputs.catppuccin.homeManagerModules.catppuccin
        ../home
      ];
    };

  # Helper function for generating host configs
  mkHost =
    {
      hostname,
      desktop ? null,
      pkgsInput ? inputs.unstable,
    }:
    pkgsInput.lib.nixosSystem {
      specialArgs = {
        inherit
          self
          inputs
          outputs
          stateVersion
          username
          hostname
          desktop
          ;
      };
      modules = [
        inputs.agenix.nixosModules.default
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.libations.nixosModules.libations
        ../host
      ];
    };

  # Helper function for generating system-manager configs
  mkSystem =
    {
      hostname,
      desktop ? null,
      pkgsInput ? inputs.unstable,
    }:
    inputs.system-manager.lib.makeSystemConfig {
      extraSpecialArgs = {
        inherit
          self
          inputs
          outputs
          stateVersion
          username
          hostname
          desktop
          ;
      };
      modules = [
        inputs.agenix.nixosModules.default
        "${self}/host/${hostname}/system.nix"
      ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
