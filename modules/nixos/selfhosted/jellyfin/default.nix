{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.jellyfin;
in
{
  options.rzi.selfhosted.jellyfin.enable = lib.mkEnableOption "Jellyfin (selfhosted)";

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/DATA/SrvData/jellyfin";
    };
  };
}
