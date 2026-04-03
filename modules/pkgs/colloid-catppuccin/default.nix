{ pkgs }:

let
  colloid-patched = pkgs.colloid-gtk-theme.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      cp ${./_color-palette-catppuccin.scss} src/sass/_color-palette-catppuccin.scss
    '';
  });
in
colloid-patched.override {
  tweaks = [ "catppuccin" ];
  colorVariants = [ "dark" ];
}
