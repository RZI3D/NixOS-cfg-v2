{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.noctalia.greeter;
in
{
  options.rzi.noctalia.greeter.enable = lib.mkEnableOption "Noctalia Greeter (nixosModule)";
  imports = [ inputs.noctalia-greeter.nixosModules.default ];
  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    security.pam.services.greetd.kwallet.enable = true;
    security.pam.services.greetd.enableGnomeKeyring.enable = true;

    programs.noctalia-greeter = {
      enable = true;
      settings = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard = {
          layout = "us";
        };
      };
    };
  };
}
