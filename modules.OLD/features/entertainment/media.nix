{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # freyr-js
        vlc
      ];
      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          enable = true;
          theme = spicePkgs.themes.catppuccin;
          enabledExtensions = with spicePkgs.extensions; [
            adblock
          ];
        };
    };
}
