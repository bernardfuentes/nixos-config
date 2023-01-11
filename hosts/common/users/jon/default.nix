{ pkgs, config, lib, outputs, ... }:
    let ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.jon = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "audio"
      "networkmanager"
      "video"
      "wheel"
    ] ++ ifExists [
      "docker"
      "lxd"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnd4bqCUEzrVkQBTVbQOKVBozJ2ZNJUFvWJFhLc7cST jon@loki"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB9bIEMgZVBCDxBWQ4m4hQP6ZZp0P3TfzjzcgUOdbYDLAAAABHNzaDo= YK5C"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBC8cs1B64XqEswY5pART6yERbjUMB7RdQdT38dgkZT6AAAABHNzaDo= YK5"
    ];
    
    packages = [ pkgs.home-manager ];
  };
}