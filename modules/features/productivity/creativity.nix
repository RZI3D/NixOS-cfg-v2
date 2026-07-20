{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.creativity =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Illustration & Image Editing
        (inkscape-with-extensions.override {
          inkscapeExtensions = [
            # Your custom working plotter tool package goes here!
            inputs.rzi-plotter.packages.${pkgs.system}.default
          ];
        })

        gimp
        krita
        # aseprite # Unfree - pixel art editor

        pixelorama # Pixel art editor (free alternative to aseprite)

        # Video & Recording
        kdePackages.kdenlive
        qpwgraph
        losslesscut-bin
        # Photo Processing
        darktable

        # Audio
        audacity
        #lmms
        google-fonts # GIVE ME ALL OF THEMMMM
        # Typography
        #fontforge
      ];
    };
}
