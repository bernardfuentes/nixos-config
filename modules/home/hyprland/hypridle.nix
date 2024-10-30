{ pkgs, ... }:
let 
  text = "rgb(251, 241, 199)";
in
{
  home.packages = [ pkgs.hypridle ];
  xdg.configFile."hypr/hypridle.conf".text = ''
  general {
    lock_cmd = swaylock
    before_sleep_cmd = swaylock
  }

  listener {
    timeout = 290
    on-timeout = pid swaylock || swaylock
  }

  listener {
    timeout = 300
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
  }
  '';
}
