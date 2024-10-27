{ pkgs, ... }: 
{
  services = {
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    dbus.enable = true;
    fstrim.enable = true;
  };
  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';
   services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  # Configure Snapper
  services.snapper = {
    # ... other configurations ...

    configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = ["bernard"];
        SPACE_LIMIT = 0.5;
        FREE_LIMIT = 0.2;
        NUMBER_CLEANUP = true;
        NUMBER_MIN_AGE = 1800;
        NUMBER_LIMIT = 50;
        NUMBER_LIMIT_IMPORTANT = 10;
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = 1800;
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 10;
        TIMELINE_LIMIT_WEEKLY = 8;
        TIMELINE_LIMIT_MONTHLY = 4;
        TIMELINE_LIMIT_YEARLY = 0;
        # cleanup empty pre-post-pairs
        EMPTY_PRE_POST_CLEANUP = true;
        # limits for empty pre-post-pair cleanup
        EMPTY_PRE_POST_MIN_AGE = 1800;
      };
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  services.udev = {
    packages = [
      pkgs.g810-led
    ];
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", RUN+="${pkgs.g810-led}/bin/g810-led -a 0000ff"
    '';
  };

  
}
