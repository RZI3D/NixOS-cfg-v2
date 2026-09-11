{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.immich;
in
{
  options.rzi.selfhosted.immich.enable = lib.mkEnableOption "Immich (selfhosted)";

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = "/mnt/DATA/SrvData/immich";
      host = "0.0.0.0";
      port = 2283;
      openFirewall = true;
      environment.IMMICH_LOG_LEVEL = "warn";
    };
  };
}
