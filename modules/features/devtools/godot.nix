{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.godot =
    { ... }:
    {
      home.packages = with pkgs; [
        godot
      ];
    };
}
