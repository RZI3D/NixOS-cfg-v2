{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.asset-server;
in
{
  options.rzi.selfhosted.asset-server.enable = lib.mkEnableOption "Caddy asset server (selfhosted)";

  config = lib.mkIf cfg.enable {
    rzi.selfhosted.podman.enable = true;

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
