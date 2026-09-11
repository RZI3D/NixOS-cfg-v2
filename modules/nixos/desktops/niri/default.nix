{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.rzi.niri;
in
{
  options.rzi.niri.enable = lib.mkEnableOption "Niri compositor (nixosModule)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bibata-cursors
    ];

    programs.niri = {
      enable = true;
      package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rzi-niri;
    };
  };
}
