{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.browsers;
in
{
  options.rzi.browsers.enable = lib.mkEnableOption "Browsers (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      helium
    ];

    programs.thunderbird = {
      enable = true;

      profiles."Zackariyya Sattaur" = {
        isDefault = true;
      };
    };
  };
}
