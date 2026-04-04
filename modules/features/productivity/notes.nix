{ self, inputs, ... }:
{
  flake.nixosModules.notes =
    { ... }:
    {
      home.packages = with pkgs; [
        anytype
      ];
    };
}
