{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.notes;
  # logseqAppImage = pkgs.appimageTools.wrapType2 {
  #   pname = "logseq";
  #   version = "0.10.15";
  #   src = pkgs.fetchurl {
  #     url = "https://github.com/logseq/logseq/releases/download/0.10.15/Logseq-linux-x64-0.10.15.AppImage";
  #     sha256 = "sha256-i5EQUvSW1ix+8NT8nCs6mGH2B9xF7G4mB7vBhDJ7JdE=";
  #   };
  # };
  silverBullet = pkgs.appimageTools.wrapType2 {
    pname = "silverbullet";
    version = "2.10.0";
    src = pkgs.fetchurl {
      url = "https://releases.silverbullet.plus/releases/2.10.0/SilverBullet_x86_64.AppImage";
      sha256 = "sha256-dgqQOkxKIlRE/sLUfWLDELAoFK9tvVbkvzqApJuCtFw=";
    };
  };
in
{
  options.rzi.notes.enable = lib.mkEnableOption "Notes & knowledge management (hmModule)";

  config = lib.mkIf cfg.enable {
    # xdg.desktopEntries.logseq = {
    #   name = "Logseq";
    #   exec = "${logseqAppImage}/bin/logseq";
    #   icon = "logseq";
    #   comment = "Privacy-first, open-source platform for knowledge management";
    #   categories = [ "Office" "Utility" ];
    # };

    xdg.desktopEntries.silverbullet = {
      name = "SilverBullet";
      exec = "${silverBullet}/bin/silverbullet";
      icon = "silverbullet";
      comment = "Your #Programmable Personal Knowledge Database";
      categories = [
        "Office"
        "Utility"
      ];
    };
  };
}
