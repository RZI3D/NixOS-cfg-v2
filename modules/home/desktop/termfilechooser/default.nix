{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.termfilechooser-portal;
in
{
  options.rzi.termfilechooser-portal.enable = lib.mkEnableOption "termfilechooser (hmModule)";

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      GTK_USE_PORTAL = "1";
      GDK_DEBUG = "portals";
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-termfilechooser
      ];
      config.common = {
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };

    # Termfilechooser config
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/superfile-wrapper.sh
      default_dir=$HOME
      env=PATH="$PATH:/run/current-system/sw/bin"
      env=TERMCMD='kitty --title "termfilechooser"'
      open_mode=suggested
      save_mode=last
    '';

    home.packages = with pkgs; [
      superfile
      (pkgs.writeShellScriptBin "spf" ''exec ${pkgs.superfile}/bin/superfile "$@"'')
      kitty
    ];

  };
}
