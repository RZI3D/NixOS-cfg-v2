{ self, ... }:
{
  flake.overlays.patched-pkgs = final: prev: {
    colloid-catppuccin =
      let
        colloid-patched = prev.colloid-gtk-theme.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            cp ${self}/modules/pkgs/colloid-catppuccin/_color-palette-catppuccin.scss src/sass/_color-palette-catppuccin.scss
          '';
        });
      in
      colloid-patched.override {
        tweaks = [ "catppuccin" ];
        colorVariants = [ "dark" ];
      };

    qt6ct-kde = prev.qt6Packages.qt6ct.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ "${self}/modules/pkgs/qt6ct-kde/qt6ct-kde.patch" ];
    });
  };
}
