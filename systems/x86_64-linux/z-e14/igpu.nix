{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime-legacy1
      vulkan-validation-layers
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
