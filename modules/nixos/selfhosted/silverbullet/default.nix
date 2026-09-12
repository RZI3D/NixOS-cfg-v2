{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.silverbullet;
in
{
  options.rzi.selfhosted.silverbullet.enable =
    lib.mkEnableOption "Silverbullet Server (nixosModule/hmModule)";

  config = lib.mkIf cfg.enable {
    rzi.selfhosted.podman.enable = true;
    virtualisation.oci-containers.containers.silverbullet = {
      image = "ghcr.io/silverbulletmd/silverbullet:edge";
      ports = [ "0.0.0.0:3005:3000" ];
      volumes = [ "/mnt/DATA/SrvData/silverbullet:/data" ];
      environment = {
        SB_HOSTNAME = "0.0.0.0";
      };
    };
  };
}
