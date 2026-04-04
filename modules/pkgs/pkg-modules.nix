{ self, ... }:
{
  flake.homeModules.firefoxWebapps = import "${self}/modules/pkgs/firefox-webapps";
  flake.homeModules.colloidCatppuccin = import "${self}/modules/pkgs/colloid-catppuccin";
  flake.homeModules.qt6ct-kde = import "${self}/modules/pkgs/qt6ct-kde";
}
