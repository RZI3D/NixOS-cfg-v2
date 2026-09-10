{
  self,
  inputs,
  ...
}:
{
  flake.homeModules.notes =
    { pkgs, ... }:
    let

      logseqAppImage = pkgs.appimageTools.wrapType2 {
        pname = "logseq";
        version = "0.10.15";
        src = pkgs.fetchurl {
          url = "https://github.com/logseq/logseq/releases/download/0.10.15/Logseq-linux-x64-0.10.15.AppImage";
          sha256 = "sha256-i5EQUvSW1ix+8NT8nCs6mGH2B9xF7G4mB7vBhDJ7JdE=";
        };
      };

    in
    {
#       home.packages = with pkgs; [
#         logseq
#       ];

      xdg.desktopEntries.logseq = {
        name = "Logseq";
        exec = "${logseqAppImage}/bin/logseq";
        icon = "logseq";
        comment = "Privacy-first, open-source platform for knowledge management";
        categories = [ "Office" "Utility" ];
      };

    };
}
