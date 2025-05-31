{ inputs, pkgs, ...}: 
{
  home.packages = with pkgs; [
    swww
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    hyprpicker
    inputs.hyprmag.packages.${pkgs.system}.hyprmag
    grim
    slurp
    clipman
    wf-recorder
    glib
    wayland
    direnv
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    systemd.enable = true;
    settings = {
      debug = {
	      disable_logs = false;
      };
    };
  };
}
