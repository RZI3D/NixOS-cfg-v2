{ self, ... }:
{
  flake.homeModules.firefoxWebapps = import "${self}/modules/pkgs/firefox-webapps";
  flake.overlays.patched-pkgs = final: prev: {
    colloid-catppuccin = prev.callPackage "${self}/modules/pkgs/colloid-catppuccin" { pkgs = prev; };
    qt6ct-kde = prev.callPackage "${self}/modules/pkgs/qt6ct-kde" { pkgs = prev; };
  };
}
