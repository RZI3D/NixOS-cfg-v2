{ self, inputs,  ... }:
{
  flake.overlays.patched-pkgs = final: prev: {

    # openbubbles-app = inputs.openbubbles-app.packages.${final.system}.openbubbles-app;

    freyr-js = inputs.freyr-js.packages.${final.system}.freyr-js;

    colloid-catppuccin =
      let
        colloid-patched = prev.colloid-gtk-theme.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            cp ${self}/pkgs/colloid-catppuccin/_color-palette-catppuccin.scss src/sass/_color-palette-catppuccin.scss
          '';
        });
      in
      colloid-patched.override {
        tweaks = [ "catppuccin" ];
        colorVariants = [ "dark" ];
      };

    qt6ct-kde = prev.qt6Packages.qt6ct.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (builtins.path {
          path = "${self}/pkgs/qt6ct-kde/qt6ct-kde.patch";
          name = "qt6ct-kde.patch";
        })
      ];
    });
  };
}
