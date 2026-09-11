{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.grimmory;
in
{
  options.rzi.selfhosted.grimmory.enable = lib.mkEnableOption "Grimmory (selfhosted)";

  config = lib.mkIf cfg.enable {
    rzi.selfhosted.podman.enable = true;

    sops.templates."grimmory-db.env".content = ''
      MARIADB_ROOT_PASSWORD=${config.sops.placeholder."grimmory/db_root_password"}
      MARIADB_PASSWORD=${config.sops.placeholder."grimmory/db_user_password"}
    '';

    sops.templates."grimmory.env".content = ''
      DATABASE_PASSWORD=${config.sops.placeholder."grimmory/db_user_password"}
    '';

    sops.secrets = {
      "grimmory/db_root_password" = { };
      "grimmory/db_user_password" = { };
    };

    virtualisation.oci-containers.containers = {

      grimmory-db = {
        image = "mariadb:11";
        environmentFiles = [ config.sops.templates."grimmory-db.env".path ];
        environment = {
          MARIADB_DATABASE = "grimmory";
          MARIADB_USER = "grimmory";
        };
        volumes = [
          "/var/lib/grimmory/mysql:/var/lib/mysql"
        ];
      };

      grimmory = {
        image = "ghcr.io/grimmory-tools/grimmory:v3.2.2";
        dependsOn = [ "grimmory-db" ];
        ports = [ "6060:6060" ];
        environmentFiles = [ config.sops.templates."grimmory.env".path ];
        environment = {
          DATABASE_URL = "jdbc:mariadb://grimmory-db:3306/grimmory";
          DATABASE_USERNAME = "grimmory";
        };
        volumes = [
          "/mnt/DATA/SrvData/grimmory/books:/books"
          "/mnt/DATA/SrvData/grimmory/bookdrop:/bookdrop"
          "/mnt/DATA/SrvData/grimmory/data:/app/data"
        ];
      };

    };
  };
}
