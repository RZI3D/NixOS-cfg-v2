{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.theme;
in
{
  options.rzi.theme.enable = lib.mkEnableOption "Theme (hmModule)";
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    # TODO: Some of these should be moved to their own modules, but for now they are here
    ./eza.nix
    ./nu.nix
    ./carapace.nix
    ./kitty.nix
    ./fish.nix
    ./zoxide.nix
    ./starship.nix
    ./qt.nix
    ./gtk.nix
  ];

  config = lib.mkIf cfg.enable {
    catppuccin.flavor = "mocha";
    catppuccin.accent = "sapphire";
    catppuccin.enable = true;
    catppuccin.autoEnable = true;

    # TODO: Put this in its own module
    programs.nix-index = {
      enable = true;
      package =
        inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-small-db;
    };

    home.packages = with pkgs; [
      comma
    ];

  };
}
