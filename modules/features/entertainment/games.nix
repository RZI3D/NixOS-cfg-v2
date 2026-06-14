{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.games =
    { pkgs, inputs, ... }:
    {
      programs.steam.enable = true;

      environment.systemPackages = with pkgs; [
        lutris
        #wineWow64Packages.stagingFull
        winetricks
        vulkan-tools
        vulkan-loader
        pkgsi686Linux.vulkan-loader
        pkgsi686Linux.libva
        pkgsi686Linux.mesa
        mangohud
        goverlay
        nixgl.nixGLIntel
      ];

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc.lib
        libxxf86vm # Minecraft JavaFX
        zlib
        libGL
        SDL2
        libpulseaudio
        udev
        libX11
        libXcursor
        libXrandr
        libXi
        libXext
      ];

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
    };
  flake.homeModules.games =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        lumafly
        eden
        osu-lazer-bin
        javaPackages.compiler.temurin-bin.jdk-25 # Minecraft
      ];
    };
}
