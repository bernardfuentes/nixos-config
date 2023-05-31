{ lib, pkgs, runner, theme, ... }:
let
  defaults = theme { inherit pkgs; };

  greetdSwayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"
    input "type:touchpad" {
      tap enabled
    }

    xwayland disable

    bindsym XF86MonBrightnessUp exec ${pkgs.avizo}/bin/lightctl up
    bindsym XF86MonBrightnessDown exec ${pkgs.avizo}/bin/lightctl down
    bindsym Print exec ${lib.getExe pkgs.grim} /tmp/regreet.png
    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    exec "${lib.getExe pkgs.greetd.regreet} -l debug &>/tmp/regreet.log; swaymsg exit"
  '';
in
{
  environment = {
    variables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      polkit_gnome
      gnome.nautilus
      gnome.zenity

      defaults.gtkTheme.package
      defaults.fonts.default.package
      defaults.iconTheme.package
      defaults.cursorTheme.package
    ];
  };

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = defaults.wallpaper;
        fit = "Cover";
      };
      GTK = {
        cursor_theme_name = defaults.cursorTheme.name;
        font_name = "${defaults.fonts.default.name} * 12";
        icon_theme_name = defaults.iconTheme.name;
        theme_name = defaults.gtkTheme.name;
      };
    };
  };

  services = {
    dbus = {
      enable = true;
      # Make the gnome keyring work properly
      packages = [ pkgs.gnome3.gnome-keyring pkgs.gcr ];
    };

    gnome = {
      at-spi2-core.enable = true;
      gnome-keyring.enable = true;
      sushi.enable = true;
    };

    greetd = {
      enable = true;
      restart = false;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.sway} --config ${greetdSwayConfig}";
          user = "greeter";
        };
      };
    };

    gvfs.enable = true;
  };

  security = {
    pam = {
      services = {
        # allow wayland lockers to unlock the screen
        swaylock.text = "auth include login";
        # unlock gnome keyring automatically with greetd
        greetd.enableGnomeKeyring = true;
      };
    };
  };
}
