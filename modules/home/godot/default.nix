{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.godot;
in
{
  options.rzi.godot.enable = lib.mkEnableOption "Godot game engine (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      godot
    ];
  };
}