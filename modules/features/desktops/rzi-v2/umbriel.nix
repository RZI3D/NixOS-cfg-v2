{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  flake.homeModules.umbriel =
    { pkgs, ... }:
    {
      imports = [ inputs.umbriel.homeModules.default ];
      programs.umbriel = {
        enable = true;
        settings = {
          general.autostart = [
            (lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default)
          ];
          layout.gap = 5;
          input.keyboard.layout = "us";
          keybinds = {
            "Mod+Return" = "spawn:kitty";
            "Mod+Q" = "window-close";
            "Mod" = "spawn:noctalia msg panel-toggle launcher";
          };
        };
      };
    };

  flake.nixosModules.umbriel =
    { pkgs, ... }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];
      programs.umbriel.enable = true;
    };

}
