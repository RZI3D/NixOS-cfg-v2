{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.productivityCommon =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # File Management
        yazi
        kdePackages.dolphin
        kdePackages.ark # archives
        eza

        # Text Editing
        kdePackages.kate # simple text editor

        # Media Viewing
        kdePackages.gwenview # image viewer
        easyeffects # audio effects/equalizer

        # System Tools
        kdePackages.filelight # disk usage analyzer
        qalculate-gtk # powerful calculator

        # Utilities
        wl-mirror # mirror displays on Wayland
        pavucontrol # audio control
      ];
    };
  flake.nixosModules.productivityCommon =
    { pkgs, lib, ... }:
    {
      programs.weylus = {
        enable = true;
        # Point the module to use your newly defined package
        package = self.packages.${pkgs.system}.weylus-ce;
        openFirewall = true;
      };
    };
}
