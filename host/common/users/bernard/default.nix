{ pkgs, config, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.bernard = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$NBGpJh/2fmkPmP7/.w4x61$HQyMsiWb/2i9DeZgO9CsMl/HvMp8wiPSCaZ6SsvDdk0"
    shell = pkgs.zsh;
    extraGroups =
      [
        "audio"
        "networkmanager"
        "users"
        "video"
        "wheel"
      ]
      ++ ifExists [
        "docker"
        "plugdev"
        "render"
        "lxd"
      ];

    openssh.authorizedKeys.keys = [
      # "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB9bIEMgZVBCDxBWQ4m4hQP6ZZp0P3TfzjzcgUOdbYDLAAAABHNzaDo= YK5C"
      # "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBC8cs1B64XqEswY5pART6yERbjUMB7RdQdT38dgkZT6AAAABHNzaDo= YK5"
    ];

    packages = [ pkgs.home-manager ];
  };

  # This is a workaround for not seemingly being able to set $EDITOR in home-manager
  environment.sessionVariables = {
    EDITOR = "vim";
  };
}
