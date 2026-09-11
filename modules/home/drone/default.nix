{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.drone;

  # Betaflight only launches with NWJS 0.84.0; newer builds hang/crash on start.
  # This used to be a host-level `nixpkgs.overlays` entry, but under
  # snowfall/flake-utils-plus `nixpkgs.pkgs` is pre-set, so module-level
  # overlays are ignored. Override the dependency of the one package that
  # needs it instead.
  nwjs-0_84 = pkgs.nwjs.overrideAttrs {
    version = "0.84.0";
    src = pkgs.fetchurl {
      url = "https://dl.nwjs.io/v0.84.0/nwjs-v0.84.0-linux-x64.tar.gz";
      hash = "sha256-VIygMzCPTKzLr47bG1DYy/zj0OxsjGcms0G1BkI/TEI=";
    };
  };
in
{
  options.rzi.drone.enable = lib.mkEnableOption "Drone tools (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (betaflight-configurator.override { nwjs = nwjs-0_84; })
    ];
  };
}
