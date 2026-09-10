{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.recording =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        obs-cmd
      ];

      programs.obs-studio = {
        enable = true;

        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          self.packages.${pkgs.system}.vinciFlow
          obs-advanced-masks
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi

          obs-aitum-multistream
          obs-vertical-canvas

          obs-gstreamer
          obs-vkcapture
        ];
      };
    };
}
