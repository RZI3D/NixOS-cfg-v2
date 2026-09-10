{ ... }:
{
  flake.nixosModules."selfhosted-jellyfin" =
    { ... }:
    {
      services.jellyfin = {
        enable = true;
        openFirewall = true;
        dataDir = "/mnt/DATA/SrvData/jellyfin";
      };
    };
}