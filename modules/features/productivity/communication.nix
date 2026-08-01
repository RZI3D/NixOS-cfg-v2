{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.homeModules.communication =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        equibop
        ayugram-desktop
        zapzap
        parsec-bin
        fluffychat
      ];

      xdg.desktopEntries = {
#         discord = {
#           name = "EquibBop (Optimized)";
#           genericName = "Customizable Discord app";
#           comment = "Equibop is a customizable and privacy friendly Discord desktop app!";
#           exec = "equibop --ozone-platform=x11 --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds --use-gl=angle --use-angle=gl --enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks %U";
#           icon = "equibop"; # Pulls the official system Discord icon automatically
#           terminal = false;
#           categories = [
#             "Network"
#             "InstantMessaging"
#             "Chat"
#           ];
#           mimeType = [ "x-scheme-handler/discord" ];
#         };
      };

    };
}
