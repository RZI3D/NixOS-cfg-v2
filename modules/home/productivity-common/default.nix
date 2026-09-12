{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.productivity-common;

  # Applied locally on purpose: a global dolphin overlay wraps the package with
  # its `.dev` output, which drags the whole KDE dev closure onto every host
  # (e.g. the Plasma server rzi-mac-pro) even though the "Open with outside
  # KDE" fix is only relevant on the non-KDE desktops.
  pkgs' = pkgs.extend inputs.dolphin-overlay.overlays.default;
in
{
  options.rzi.productivity-common.enable = lib.mkEnableOption "Common productivity packages (nixosModule)";

  config = lib.mkIf cfg.enable {
    programs.superfile.enable = true;

    home.packages = with pkgs; [
      pkgs'.kdePackages.dolphin
      kdePackages.ark
      motrix-next
      kdePackages.kate
      kdePackages.gwenview
      # yazi # superfile is better imo
      easyeffects
      kdePackages.filelight
      qalculate-gtk
      pavucontrol
    ];
  };
}
