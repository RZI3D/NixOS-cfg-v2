{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.rzi.minecraft-servers;
in
{
  options.rzi.minecraft-servers.enable = lib.mkEnableOption "Minecraft servers (nixosModule)";

  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.playit-nixos-module.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    # NOTE: the nix-minecraft overlay is applied globally via `overlays/nix-minecraft`,
    # because FUP/snowfall sets `nixpkgs.pkgs` and module-level `nixpkgs.overlays`
    # would otherwise be ignored (the upstream module defaults to `pkgs.minecraft-server`).

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

    services.playit = {
      enable = true;
      secretPath = config.sops.secrets.playit-secret.path;
    };
  };
}