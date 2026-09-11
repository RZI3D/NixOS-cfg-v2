{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.romm;
in
{
  options.rzi.selfhosted.romm.enable = lib.mkEnableOption "RomM (selfhosted)";

  config = lib.mkIf cfg.enable {
    rzi.selfhosted.podman.enable = true;

    sops.templates."romm-db.env".content = ''
      MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm/MARIADB_ROOT_PASSWORD"}
      MARIADB_PASSWORD=${config.sops.placeholder."romm/MARIADB_PASSWORD"}
    '';

    sops.templates."romm.env".content = ''
      DB_PASSWD=${config.sops.placeholder."romm/DB_PASSWD"}
      ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/ROMM_AUTH_SECRET_KEY"}
      IGDB_CLIENT_ID=${config.sops.placeholder."romm/IGDB_CLIENT_ID"}
      IGDB_CLIENT_SECRET=${config.sops.placeholder."romm/IGDB_CLIENT_SECRET"}
      SCREENSCRAPER_USER=${config.sops.placeholder."romm/SCREENSCRAPER_USER"}
      SCREENSCRAPER_PASSWORD=${config.sops.placeholder."romm/SCREENSCRAPER_PASSWORD"}
      STEAMGRIDDB_API_KEY=${config.sops.placeholder."romm/STEAMGRIDDB_API_KEY"}
      OIDC_CLIENT_ID=${config.sops.placeholder."romm/OIDC_CLIENT_ID"}
      OIDC_CLIENT_SECRET=${config.sops.placeholder."romm/OIDC_CLIENT_SECRET"}
    '';

    sops.secrets = {
      "romm/MARIADB_ROOT_PASSWORD" = { };
      "romm/MARIADB_PASSWORD" = { };
      "romm/DB_PASSWD" = { };
      "romm/ROMM_AUTH_SECRET_KEY" = { };
      "romm/IGDB_CLIENT_ID" = { };
      "romm/IGDB_CLIENT_SECRET" = { };
      "romm/SCREENSCRAPER_USER" = { };
      "romm/SCREENSCRAPER_PASSWORD" = { };
      "romm/STEAMGRIDDB_API_KEY" = { };
      "romm/OIDC_CLIENT_ID" = { };
      "romm/OIDC_CLIENT_SECRET" = { };
    };

    virtualisation.oci-containers.containers = {

      romm-db = {
        image = "mariadb:latest";
        environmentFiles = [ config.sops.templates."romm-db.env".path ];
        environment = {
          MARIADB_DATABASE = "romm";
          MARIADB_USER = "romm-user";
        };
        volumes = [
          "/var/lib/romm/mysql:/var/lib/mysql"
        ];
      };

      romm = {
        image = "rommapp/romm:5.0.0-beta.2";
        dependsOn = [ "romm-db" ];
        ports = [ "8080:8080" ];
        environmentFiles = [ config.sops.templates."romm.env".path ];
        environment = {
          DB_HOST = "romm-db";
          DB_NAME = "romm";
          DB_USER = "romm-user";

          PLAYMATCH_API_ENABLED = "true";
          LAUNCHBOX_API_ENABLED = "true";
          HASHEOUS_API_ENABLED = "true";

          OIDC_ENABLED = "true";
          OIDC_PROVIDER = "authentik";
          OIDC_REDIRECT_URI = "https://romm.rzi.dpdns.org/api/oauth/openid";
          OIDC_SERVER_APPLICATION_URL = "https://auth.rzi.dpdns.org/application/o/romm/";
          OIDC_AUTOLOGIN = "true";

          OIDC_CLAIM_ROLES = "romm-groups";
          OIDC_ROLE_ADMIN = "admin";
          OIDC_ROLE_EDITOR = "editor";
          OIDC_ROLE_VIEWER = "viewer";

        };
        volumes = [
          "/mnt/DATA/SrvData/romM/library:/romm/library"
          "/mnt/DATA/SrvData/romM/resources:/romm/resources"
          "/mnt/DATA/SrvData/romM/assets:/romm/assets"
          "/mnt/DATA/SrvData/romM/redis:/redis-data"
          "/mnt/DATA/SrvData/romM/config:/romm/config"
        ];
      };

    };
  };
}
