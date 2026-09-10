{
  config,
  lib,
  pkgs,
  ...
}:
{
  # AMD Radeon RX 580 graphics card configuration

  # Packages
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      #zluda-custom
      mesa
      vulkan-loader
      vulkan-tools
    ];
  };

  environment.systemPackages = with pkgs; [
    radeontop
    amdgpu_top
  ];

  # amdgpu driver config
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amdgpu.lockup_timeout=10000"
  ];
  hardware.amdgpu.overdrive.enable = true;
}
