{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.kernels.cachyos;
in
{
  options.rzi.kernels.cachyos.enable = lib.mkEnableOption "CachyOS Kernel (nixosModule)";

  config = lib.mkIf cfg.enable {

    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.default
    ];

    # CachyOS binary cache
    nix.settings.trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
    nix.settings.substituters = [
      "https://attic.xuyh0120.win/lantian"
    ];

    # Sets CachyOS kernel as the boot kernel
    boot.kernelPackages =
      (pkgs.appendOverlays [
        inputs.nix-cachyos-kernel.overlays.default
      ]).cachyosKernels.linuxPackages-cachyos-latest;

  };
}
