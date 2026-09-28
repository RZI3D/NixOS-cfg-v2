{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.microcontroller-dev;
in
{
  options.rzi.microcontroller-dev.enable = lib.mkEnableOption "Microcontroller development tools (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      arduino-ide
      arduino
      kicad
    ];
  };
}
