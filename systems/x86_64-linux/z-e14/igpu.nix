{
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa.opencl # rusticl; replaces intel-compute-runtime-legacy1 for this test
      vulkan-validation-layers
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables.RUSTICL_ENABLE = "iris";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

}
