{ config, self, ... }:
{
  imports = [ ../common/services/mullvad.nix ];

  age.secrets = {
    borgbase-ssh = {
      file = "${self}/secrets/kara-borgbase-ssh.age";
      owner = "root";
      group = "root";
      mode = "400";
    };
    borgbase-passphrase = {
      file = "${self}/secrets/kara-borgbase-passphrase.age";
      owner = "root";
      group = "root";
      mode = "400";
    };
  };

  services = {
    ollama = {
      enable = true;
      acceleration = "rocm";
      listenAddress = "kara.tailnet-d5da.ts.net:11434";
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0";
      };
    };
    # In order to mount the backup to restore files, perform the following:
    #
    #    mkdir backup
    #    sudo borg-job-borgbase mount z2sqv4mw@z2sqv4mw.repo.borgbase.com:repo ./backup
    # 
    # Then copy out the files you need using normal Linux commands. Once complete, unmount
    # with:
    #
    #    borg-job-borgbase umount backup
    borgbackup.jobs."borgbase" = {
      paths = [ "/home/jon/data" ];
      exclude = [
        "**/node_modules"
        "**/build"
        "**/dist"
        "**/.tox"
        "**/.venv"
        "**/venv"
        "**/target"
        "/home/jon/downloads"
        "/home/jon/data/downloads"
        "/home/jon/data/temp"
        "/home/jon/go"
        "/home/jon/sdk"
      ];
      repo = "z2sqv4mw@z2sqv4mw.repo.borgbase.com:repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets."borgbase-passphrase".path}";
      };
      environment.BORG_RSH = "ssh -i ${config.age.secrets."borgbase-ssh".path}";
      compression = "auto,lzma";
      startAt = "*-*-* 12:00:00";
    };
  };
}
