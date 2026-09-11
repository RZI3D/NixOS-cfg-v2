{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.authentik;
in
{
  options.rzi.selfhosted.authentik.enable = lib.mkEnableOption "Authentik identity provider (selfhosted)";

  config = lib.mkIf cfg.enable {
    rzi.selfhosted.podman.enable = true;

    sops.templates."authentik.env".content = ''
      PG_USER=authentik
      PG_DB=authentik
      PG_PASS=${config.sops.placeholder."authentik/pg_pass"}
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}

      POSTGRES_PASSWORD=${config.sops.placeholder."authentik/pg_pass"}
      POSTGRES_USER=authentik
      POSTGRES_DB=authentik
    '';

    sops.secrets."authentik/pg_pass" = { };
    sops.secrets."authentik/secret_key" = { };

    virtualisation.oci-containers.containers = {

      authentik-postgresql = {
        image = "docker.io/library/postgres:16-alpine";
        environmentFiles = [ config.sops.templates."authentik.env".path ];
        environment = {
          POSTGRES_DB = "authentik";
          POSTGRES_USER = "authentik";
        };
        volumes = [
          "/var/lib/authentik/postgres:/var/lib/postgresql/data"
        ];
        extraOptions = [ "--health-cmd=pg_isready -d authentik -U authentik" ];
        autoStart = true;
      };

      authentik-server = {
        image = "ghcr.io/goauthentik/server:2026.5.3";
        dependsOn = [ "authentik-postgresql" ];
        environmentFiles = [ config.sops.templates."authentik.env".path ];
        environment = {
          AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
          AUTHENTIK_POSTGRESQL__NAME = "authentik";
          AUTHENTIK_POSTGRESQL__USER = "authentik";
        };
        cmd = [ "server" ];
        ports = [
          "9000:9000"
          "9443:9443"
        ];
        volumes = [
          "/var/lib/authentik/data:/data"
          "/var/lib/authentik/custom-templates:/templates"
          "/var/lib/authentik/media:/media"
        ];
        extraOptions = [ "--shm-size=512m" ];
        autoStart = true;
      };

      authentik-worker = {
        image = "ghcr.io/goauthentik/server:2026.5.3";
        dependsOn = [ "authentik-postgresql" ];
        environmentFiles = [ config.sops.templates."authentik.env".path ];
        environment = {
          AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
          AUTHENTIK_POSTGRESQL__NAME = "authentik";
          AUTHENTIK_POSTGRESQL__USER = "authentik";
        };
        cmd = [ "worker" ];
        volumes = [
          "/var/lib/authentik/data:/data"
          "/var/lib/authentik/custom-templates:/templates"
          "/var/lib/authentik/media:/media"
        ];
        extraOptions = [ "--shm-size=512m" ];
        autoStart = true;
      };
    };
  };
}
