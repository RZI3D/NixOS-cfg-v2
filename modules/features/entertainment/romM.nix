{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.romMServer =
    { pkgs, inputs, ... }:
    {
        virtualisation.oci-containers.containers."romm-db" = {
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

        virtualisation.oci-containers.containers."romm" = {
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
            "/mnt/DATA/Games/romM/library:/roms"
            "/mnt/DATA/Games/romM/resources:/romm/resources"
            "/mnt/DATA/Games/romM/assets:/romm/assets"
            "/mnt/DATA/Games/romM/redis:/redis-data"
            "/mnt/DATA/Games/romM/config:/romm/config"
            ];
        };
    };
}
