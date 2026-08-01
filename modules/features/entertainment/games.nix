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

      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraArgs = "-system-composer";
        };
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
        gpu-screen-recorder-gtk
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

    };
  flake.homeModules.games =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        lumafly
        eden
        osu-lazer-bin
        moonlight-qt
        javaPackages.compiler.temurin-bin.jdk-25 # Minecraft
        (pkgs.symlinkJoin {
          name = "flightgear-wrapped";
          paths = [ pkgs.flightgear ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/fgfs --unset QML2_IMPORT_PATH --unset QML_IMPORT_PATH
          '';
        })
      ];
    };
}
