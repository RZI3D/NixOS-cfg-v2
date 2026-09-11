{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.creativity;
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
  options.rzi.creativity.enable = lib.mkEnableOption "Creative tools (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (inkscape-with-extensions.override {
        inkscapeExtensions = [
          inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rzi-inkscape-plotter-tools
        ];
      })
      gimp
      krita
      pixelorama
      kdePackages.kdenlive
      qpwgraph
      losslesscut-bin
      darktable
      audacity
    ];

    xdg.desktopEntries.audacity = {
      name = "Audacity (Beta)";
      exec = "${audacityAppImage}/bin/audacity";
      icon = "audacity";
      comment = "Free, open source, cross-platform audio software for multi-track recording and editing.";
      categories = [ "AudioVideo" "Audio" "Recorder" ];
    };
  };
}