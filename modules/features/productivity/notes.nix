{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.notes =
    { ... }:
    {
      home.packages = with pkgs; [
        anytype
      ];
    };
}
