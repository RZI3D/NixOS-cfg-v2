{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  rzi.theme.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    templates = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };

  home.packages = [ pkgs.hello ];
  home.stateVersion = "26.05";

  # home.username / home.homeDirectory are auto-set by Snowfall
  # (snowfallorg.user.enable defaults to true when created via homes/)
}
