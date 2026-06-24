{ config, pkgs, inputs, ... }:
{
  flake.homeModules.podmanStacks =
    { pkgs, config, ... }:
    {
        imports = [
            inputs.nix-podman-stacks.homeModules.nps
        ];

        #virtualisation.podman.enable = true;

        nps.externalStorageBaseDir = "/mnt/DATA/Linux/container-storage";

        nps.stacks = {
          #homepage.enable = true;

#           traefik = {
#             enable = true;
#             domain = "rzi-mac-pro.tail4bd02b.ts.net";
#           };

          grimmory = {
            enable = true;
            oidc.registerClient = true;
            db = {
              userPasswordFile = config.sops.secrets."grimmory/db_user_password".path;
              rootPasswordFile = config.sops.secrets."grimmory/db_root_password".path;
            };
          };
        };

      services.podman.containers.grimmory.expose = true;

    };
}
