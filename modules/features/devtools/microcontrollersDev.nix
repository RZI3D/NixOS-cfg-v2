{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.microcontrollerDev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        arduino-ide
        arduino # v1 ide. some of my microcontrollers still need it
        
      ];
    };
}
