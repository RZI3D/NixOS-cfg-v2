{ ... }:
{
  flake.nixosModules."selfhosted-audiobookshelf" =
    { ... }:
    {
      services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = 7070;
        openFirewall = true;
      };
    };
}