{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.communication =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        discord-ptb
        ayugram-desktop
        whatsapp-electron
        parsec-bin
        # openbubbles-app
      ];
    };
}
