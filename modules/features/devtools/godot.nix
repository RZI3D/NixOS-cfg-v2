{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.godot =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        godot
      ];
    };
}
