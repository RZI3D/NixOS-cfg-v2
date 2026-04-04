{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.creativity =
    { ... }:
    {
      home.packages = with pkgs; [
        # Illustration & Image Editing
        inkscape
        gimp
        krita
        aseprite # Unfree - pixel art editor

        # 3D & Game Art
        blender
        pixelorama # Pixel art editor (free alternative to aseprite)

        # Video & Recording
        kdePackages.kdenlive
        # obs-studio
        obs-cmd
        qpwgraph
        losslesscut-bin
        # Photo Processing
        darktable

        # Audio
        audacity
        lmms

        # Typography
        fontforge
      ];

      programs.obs-studio = {
        enable = true;

        # optional Nvidia hardware acceleration
        # package = (
        #   pkgs.obs-studio.override {
        #     cudaSupport = true;
        #   }
        # );

        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi # optional AMD hardware acceleration

          obs-aitum-multistream
          obs-vertical-canvas

          obs-gstreamer
          obs-vkcapture
        ];
      };
    };
}
