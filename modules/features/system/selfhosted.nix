{
  config,
  pkgs,
  inputs,
  ...
}:
{
  flake.nixosModules.selfHostedServices =
    { pkgs, config, ... }:
    let
      replicationPkg =
        ps:
        ps.buildPythonPackage rec {
          pname = "replication";
          version = "0.9.11";
          format = "wheel";

          src = ps.fetchPypi {
            inherit pname version;
            format = "wheel";
            dist = "py3";
            python = "py3";
            abi = "none";
            platform = "any";
            hash = "sha256-lLoGNtCx5+hertFLvA3d6HbD61JZlGQlPYyqtETdhh4=";
          };

          nativeBuildInputs = [ ps.pythonRelaxDepsHook ];

          pythonRemoveDeps = [
            "pyzmq"
            "deepdiff"
          ];

          propagatedBuildInputs = [
            ps.pyzmq
            ps.deepdiff
          ];

          doCheck = false;
        };

      replication-server = pkgs.dockerTools.streamLayeredImage {
        name = "replication-server";
        tag = "latest";

        contents = [
          (pkgs.python3.withPackages (ps: [
            (replicationPkg ps)
          ]))
          pkgs.coreutils
          pkgs.bash
        ];

        config = {

          Cmd = [
            "bash"
            "-c"
            "exec replication.server -p \"$port\" -apwd \"$admin_password\" -spwd \"$password\" -t \"$timeout\" -l \"$log_level\""
          ];

          Env = [ "PYTHONUNBUFFERED=1" ];
        };
      };
    in
    {

      sops.templates."grimmory-db.env".content = ''
        MARIADB_ROOT_PASSWORD=${config.sops.placeholder."grimmory/db_root_password"}
        MARIADB_PASSWORD=${config.sops.placeholder."grimmory/db_user_password"}
      '';

      sops.templates."grimmory.env".content = ''
        DATABASE_PASSWORD=${config.sops.placeholder."grimmory/db_user_password"}
      '';

      sops.templates."multiuser.env".content = ''
        password=${config.sops.placeholder."multiuser-password"}
        admin_password=${config.sops.placeholder."multiuser-admin-password"}
      '';

      virtualisation.oci-containers.containers = {
        romm-db = {
          image = "mariadb:latest";
          environmentFiles = [ "/var/lib/romm/romm.env" ];
          environment = {
            MARIADB_DATABASE = "romm";
            MARIADB_USER = "romm-user";
          };
          volumes = [
            "/var/lib/romm/mysql:/var/lib/mysql"
          ];
        };

        romm = {
          image = "rommapp/romm:latest";
          dependsOn = [ "romm-db" ];
          ports = [ "8080:8080" ];
          environmentFiles = [ "/var/lib/romm/romm.env" ];
          environment = {
            DB_HOST = "romm-db";
            DB_NAME = "romm";
            DB_USER = "romm-user";
          };
          volumes = [
            "/mnt/DATA/Games/romM/library:/romm/library"
            "/mnt/DATA/Games/romM/resources:/romm/resources"
            "/mnt/DATA/Games/romM/assets:/romm/assets"
            "/mnt/DATA/Games/romM/redis:/redis-data"
            "/mnt/DATA/Games/romM/config:/romm/config"
          ];
        };

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
            "/mnt/DATA/Linux/container-storage/grimmory/books:/books"
            "/mnt/DATA/Linux/container-storage/grimmory/bookdrop:/bookdrop"
            "/mnt/DATA/Linux/container-storage/grimmory/data:/app/data"
          ];
        };

        multiuser-mdanim = {
          image = "replication-server:latest";
          imageStream = replication-server;
          ports = [ "5555-5560:5555-5560" ];
          environmentFiles = [ config.sops.templates."multiuser.env".path ];
          environment = {
            port = "5555";
            log_level = "INFO";
            timeout = "5000";
          };
        };
      };
    };
}
