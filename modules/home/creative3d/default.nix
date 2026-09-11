{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.creative3d;
in
{
  options.rzi.creative3d.enable = lib.mkEnableOption "3D creative tools (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blender
      cura-appimage
    ];
  };
}