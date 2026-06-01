{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.mcServers =
    { pkgs, inputs, ... }:
    {
      imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
      nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

      services.minecraft-servers = {

        enable = true;
        eula = true;
        openFirewall = true;

        servers = {

          neo-1_21_1 = {
            enable = true;
            package = pkgs.neoforgeServers.neoforge-1_21_1;

            serverProperties = {
              motd = "RZI Modded Minecraft Server";
              online-mode = false;
              enable-rcon = true;
              "rcon.password" = "mcrcon";
              "rcon.port" = 25575;
            };

          };

          neo-1_21_1-creative = {
            enable = true;
            package = pkgs.neoforgeServers.neoforge-1_21_1;

            serverProperties = {
              gamemode = "creative";


              server-port = 25566;
              "query.port" = 25566;

              motd = "RZI Modded Minecraft Server (Creative)";
              online-mode = false;
              enable-rcon = true;
              "rcon.password" = "mcrcon";
              "rcon.port" = 25576;
            };

          };

        };

      };

    };
}
