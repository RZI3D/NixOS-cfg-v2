{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.office;
in
{
  options.rzi.office.enable = lib.mkEnableOption "Office suite (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-qt6-fresh
      hunspell
      hunspellDicts.en_US
      kdePackages.okular
    ];
  };
}