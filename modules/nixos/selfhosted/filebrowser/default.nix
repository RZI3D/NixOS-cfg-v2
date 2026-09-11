{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.filebrowser;
in
{
  options.rzi.selfhosted.filebrowser.enable = lib.mkEnableOption "Filebrowser (selfhosted)";

  config = lib.mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      settings.root = "/mnt/DATA/SrvData/filebrowser";
      settings.address = "0.0.0.0";
      settings.port = 8069;
      openFirewall = true;
    };
  };
}
