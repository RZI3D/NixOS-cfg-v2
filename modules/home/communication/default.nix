{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.communication;
in
{
  options.rzi.communication.enable = lib.mkEnableOption "Communication apps (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (discord.override { withEquicord = true; })
      ayugram-desktop
      zapzap
      parsec-bin
      fluffychat
    ];
  };
}