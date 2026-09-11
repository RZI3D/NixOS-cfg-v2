{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.network-analysis;
in
{
  options.rzi.network-analysis.enable = lib.mkEnableOption "Network analysis tools (nixosModule)";

  config = lib.mkIf cfg.enable {
    programs.wireshark.enable = true;
  };
}