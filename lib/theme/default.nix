{ pkgs, ... }:
let
  inherit ((import ./colours.nix)) colours;
  libx = import ./lib.nix { inherit (pkgs) lib; };
in
{
  inherit (libx) hexToRgb;

  # Note that there are still places not covered by colour choices here such as:
  #  - tmux
  #  - vim
  inherit colours;

  wallpaper = ./wallpapers/jokulsarlon.jpg;

  gtkTheme = {
    name = "Catppuccin-Macchiato-Standard-Blue-Dark";
    package = pkgs.catppuccin-gtk.override {
      size = "standard";
      variant = "macchiato";
      accents = [ "blue" ];
    };
  };

  qtTheme = {
    name = "Catppuccin-Macchiato-Blue";
    package = pkgs.catppuccin-kvantum.override { variant = "Macchiato"; accent = "Blue"; };
  };

  iconTheme = rec {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
    iconPath = "${package}/share/icons/${name}";
  };

  cursorTheme = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
  };

  batTheme = {
    name = "catppuccin-macchiato";
    theme = {
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
        sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      };
      file = "Catppuccin-macchiato.tmTheme";
    };
  };

  fonts = {
    default = {
      name = "Inter";
      package = pkgs.inter;
      size = "11";
    };
    iconFont = {
      name = "Inter";
      package = pkgs.inter;
    };
    monospace = {
      name = "MesloLGSDZ Nerd Font Mono";
      package = pkgs.nerdfonts.override { fonts = [ "Meslo" ]; };
    };
    emoji = {
      name = "Joypixels";
      package = pkgs.joypixels;
    };
  };
}
