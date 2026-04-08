{ self, inputs, ... }:
{
  flake.nixosModules.rziNiri =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.rzi-niri;
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.rzi-niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {

          spawn-at-startup = [
            (lib.getExe self'.packages.rziNoctalia)
          ];

          outputs."eDP-1" = {
              mode = "1920x1080@60.00";
              scale = 1.0;
            };

          input = {
            keyboard.xkb.layout = "us";

            touchpad = {
              tap = { };
              natural-scroll = { };
            };

          };

          layout.gaps = 5;

          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
            "Mod+Q".close-window = { };
            "Mod+S".spawn-sh = "${lib.getExe self'.packages.rziNoctalia} ipc call launcher toggle";
          };
        };
      };
    };
}
