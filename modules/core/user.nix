{ pkgs, inputs, username, host, ...}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host; };
    users.${username} = {
      imports = 
        if (host == "octopus") then 
          [ ./../home/default.${host}.nix ] 
        else [ ./../home ];
      home.username = "${username}";
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = if username == "bernard" then 
      "$y$j9T$NBGpJh/2fmkPmP7/.w4x61$HQyMsiWb/2i9DeZgO9CsMl/HvMp8wiPSCaZ6SsvDdk0"
      else null;
  };
  nix.settings.allowed-users = [ "${username}" ];
}
