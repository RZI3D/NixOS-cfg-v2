{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.audiobookshelf;
in
{
  options.rzi.selfhosted.audiobookshelf.enable = lib.mkEnableOption "Audiobookshelf (selfhosted)";

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      port = 7070;
      openFirewall = true;
    };
  };
}
