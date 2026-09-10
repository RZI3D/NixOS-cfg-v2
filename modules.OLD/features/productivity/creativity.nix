{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.creativity =
    { pkgs, ... }:

    let

      audacityAppImage = pkgs.appimageTools.wrapType2 {
        pname = "audacity";
        version = "4.0.0-beta-2";
        src = pkgs.fetchurl {
          url = "https://github.com/audacity/audacity/releases/download/Audacity-4.0.0-beta-2/Audacity-4.0.0-beta2-x86_64.AppImage";
          sha256 = "sha256-HL6cp4WTujsvKQZvTK5bhdhxz++zyzuukSt9I2oHGsQ=";
        };
      };

    in

    {
      home.packages = with pkgs; [
        # Illustration & Image Editing
        (inkscape-with-extensions.override {
          inkscapeExtensions = [
            # Your custom working plotter tool package goes here!
            inputs.rzi-plotter.packages.${pkgs.stdenv.hostPlatform.system}.default
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
        # Typography
        #fontforge
      ];

      xdg.desktopEntries.audacity = {
        name = "Audacity (Beta)";
        exec = "${audacityAppImage}/bin/audacity";
        icon = "audacity";
        comment = "Free, open source, cross-platform audio software for multi-track recording and editing.";
        categories = [
          "AudioVideo"
          "Audio"
          "Recorder"
        ];
      };

    };
}
