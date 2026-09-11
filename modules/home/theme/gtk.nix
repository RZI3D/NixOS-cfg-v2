{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  colloid-catppuccin = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.colloid-catppuccin;
  themeName = "Colloid-Dark-Catppuccin";

in
{
  # GTK
  gtk = {
    enable = true;
    theme = {
      name = themeName;
      package = colloid-catppuccin;
    };
  };

  xdg.configFile = {
    "gtk-4.0/gtk.css".source = "${colloid-catppuccin}/share/themes/${themeName}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${colloid-catppuccin}/share/themes/${themeName}/gtk-4.0/gtk-dark.css";
    "gtk-4.0/assets" = {
      recursive = true;
      source = "${colloid-catppuccin}/share/themes/${themeName}/gtk-4.0/assets";
    };
  };

  # gtk.iconTheme = {
  #   name = "Papirus-Dark";
  #   package = pkgs.papirus-icon-theme;
  # };

  gtk.gtk4.theme = config.gtk.theme;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = themeName;
    };
  };
}
