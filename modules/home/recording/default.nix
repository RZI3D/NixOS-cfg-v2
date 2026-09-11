{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.recording;
in
{
  options.rzi.recording.enable = lib.mkEnableOption "Recording & streaming tools (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obs-cmd
    ];

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.vinci-flow
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