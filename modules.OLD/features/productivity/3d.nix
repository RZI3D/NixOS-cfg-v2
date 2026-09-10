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
        # openscad-unstable # TODO: Re-enable when hydra build passes
        # freecad # TODO: Re-enable when hydra build passes
        cura-appimage
      ];
    };
}
