{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    # Later, might not even be needed
  ];
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

  rzi.umbriel.enable = true;
  rzi.noctalia.shell.enable = true;
  rzi.theme.enable = true;
  rzi.browsers.enable = true;
  rzi.productivity-common.enable = true;
  rzi.communication.enable = true;
  rzi.creativity.enable = true;
  rzi.notes.enable = true;
  rzi.office.enable = true;
  rzi.recording.enable = true;
  rzi.creative3d.enable = true;
  rzi.devtools.enable = true;
  rzi.drone.enable = true;
  rzi.godot.enable = true;
  rzi.microcontroller-dev.enable = true;
  rzi.media.enable = true;
  rzi.games.enable = true;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  # home.packages = [ pkgs.hello ];
  home.stateVersion = "26.05";

  # home.username / home.homeDirectory are auto-set by Snowfall
  # (snowfallorg.user.enable defaults to true when created via homes/)
}
