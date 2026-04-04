{ self, inputs, pkgs ... }:
{
  flake.nixosModules.communication = { ... }: {
    home.packages = with pkgs; [
      discord-ptb
      ayugram-desktop
      whatsapp-electron
      parsec-bin
    ];
  };
}
