{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.drone =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        betaflight-configurator
      ];
    };
}
