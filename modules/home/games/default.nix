{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.games;
in
{
  options.rzi.games.enable = lib.mkEnableOption "Gaming packages (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      flightgear
      lumafly
      eden
      osu-lazer-bin
      moonlight-qt
      javaPackages.compiler.temurin-bin.jdk-25
    ];
  };
}
