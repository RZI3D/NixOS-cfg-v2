{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--header"
      "--sort=type"
      "--no-permissions"
      "--hyperlink"
      "--level=3"
      "--git-ignore"
      "--time=created"
      "--time-style=long-iso"
      "--short-nix"
    ];
  };
}
