{
  self,
  ...
}:
{
  flake.nixosModules."selfhosted-asset-server" =
    { ... }:
    {
      imports = [ self.nixosModules."selfhosted-podman" ];

      virtualisation.oci-containers.containers.asset-server = {
        image = "docker.io/library/caddy:latest";
        ports = [ "127.0.0.1:8091:80" ];
        volumes = [
          "/srv/assets:/srv/assets:ro"
        ];
        cmd = [
          "caddy"
          "file-server"
          "--root"
          "/srv/assets"
          "--browse=false"
        ];
      };

    };
}