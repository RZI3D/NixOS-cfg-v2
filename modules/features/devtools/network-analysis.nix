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
      programs.wireshark.enable = true;
    };
}
