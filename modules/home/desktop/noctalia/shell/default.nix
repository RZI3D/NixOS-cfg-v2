{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.noctalia.shell;
in
{
  options.rzi.noctalia.shell.enable = lib.mkEnableOption "Noctalia Shell (hmModule)";

  imports = [ inputs.noctalia.homeModules.default ];

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      # For Screen Toolkit
      slurp
      grim
      hyprpicker
      tesseract
      imagemagick
      zbar
      curl
      jq
      bc
      mpv
      swappy
      satty
      translate-shell
      mpvpaper
      # For the gamelauncher
      clang # idk either man
    ];

    programs.noctalia = {
      enable = true;

      #         settings = { # This may also be a string or path to a .toml file.
      #           theme = {
      #             mode = "dark";
      #             source = "builtin";
      #             builtin = "Catppuccin";
      #           };
      #
      #           wallpaper = {
      #             enabled = true;
      #             default.path = "/path/to/wallpapers/wallpaper.png";
      #           };
      #         };

    };

  };
}
