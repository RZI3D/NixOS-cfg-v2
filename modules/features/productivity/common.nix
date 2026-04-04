{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.productivityCommon =
    { ... }:
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
        vlc # video player
        easyeffects # audio effects/equalizer

        # System Tools
        kdePackages.filelight # disk usage analyzer
        qalculate-gtk # powerful calculator

        # Connectivity
        networkmanagerapplet # wifi tray applet
        blueman # bluetooth manager

        # Utilities
        wl-mirror # mirror displays on Wayland
        pavucontrol # audio control
      ];
    };
}
