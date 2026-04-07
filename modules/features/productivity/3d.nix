{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.creative3d =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        blender
        openscad-unstable
        freecad
      ];
    };
}
