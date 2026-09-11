{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.corepkgs;
in
{
  options.rzi.corepkgs.enable = lib.mkEnableOption "Core NixOS packages and utilities (nixosModule)";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      git
      python3
      wireplumber
      usbutils
      curl
      ripgrep
      ffmpeg
      libnotify
      playerctl
      wl-clipboard
      brightnessctl
      wireguard-tools
      proton-vpn
    ];
  };
}
