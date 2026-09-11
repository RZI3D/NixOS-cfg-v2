{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.rzi.games;
in
{
  options.rzi.games.enable = lib.mkEnableOption "Gaming (nixosModule)";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override { extraArgs = "-system-composer"; };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

    programs.opengamepadui = {
      enable = true;
      gamescopeSession.enable = true;
      inputplumber.enable = true;
    };

    programs.gpu-screen-recorder.enable = true;

    environment.systemPackages = with pkgs; [
      lutris
      heroic
      winetricks
      vulkan-tools
      vulkan-loader
      pkgsi686Linux.vulkan-loader
      pkgsi686Linux.libva
      pkgsi686Linux.mesa
      mangohud
      goverlay
      nixgl.nixGLIntel
      gpu-screen-recorder-gtk
    ];

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc.lib
      libxxf86vm
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
  };
}