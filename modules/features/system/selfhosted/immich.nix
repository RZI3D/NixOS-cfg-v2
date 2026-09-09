{ ... }:
{
  flake.nixosModules."selfhosted-immich" =
    { ... }:
    {
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