{ pkgs, ... }:
let 
  text = "rgb(251, 241, 199)";
in
{
  home.packages = [ pkgs.hypridle ];
  xdg.configFile."hypr/hypridle.conf".text = ''
  general {
    lock_cmd = swaylock
  }

  listener {
    timeout = 200
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl displatch dpms on
  }
  '';
}
