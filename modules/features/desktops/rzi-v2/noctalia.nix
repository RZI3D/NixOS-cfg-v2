{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  flake.homeModules.noctalia =
    { pkgs, ... }:
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

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
        ffmpeg-full
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
