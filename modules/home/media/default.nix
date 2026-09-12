{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.media;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.rzi.media.enable = lib.mkEnableOption "Media apps & spicetify (hmModule)";

  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
      ffmpeg
    ];

    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
      ];
    };
  };
}
