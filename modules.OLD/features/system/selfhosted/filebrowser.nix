{ ... }:
{
  flake.nixosModules."selfhosted-filebrowser" =
    { ... }:
    {
      services.filebrowser = {
        enable = true;
        settings.root = "/mnt/DATA/SrvData/filebrowser";
        settings.address = "0.0.0.0";
        settings.port = 8069;
        openFirewall = true;
      };
    };
}