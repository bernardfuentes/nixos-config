{ pkgs, ... }:
let 
  text = "rgb(251, 241, 199)";
in
{
  home.packages = [ pkgs.hypridle ];
  xdg.configFile."hypr/hypridle.conf".text = ''
  general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
  }

  listener {
    timeout = 20
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl displatch dpms on
  }
  '';
}
