{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.notes;
  pname = "silverbullet";
  version = "2.11.0-edge";
  src = pkgs.fetchurl {
    url = "https://release.silverbullet.md/electron/artifacts/2.11.0-edge.20261001T1421/linux/x64/SilverBullet-2.11.0-edge.20261001T1421-linux-x86_64.AppImage";
    sha256 = "sha256-DVHa4LxdE1QBnSE9bYwnLV2mzhXZOaQfwgoEL6Ffxew=";
  };
  extracted = pkgs.appimageTools.extract { inherit pname version src; };
  silverBullet = pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm444 ${extracted}/*.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/*.desktop \
        --replace-quiet 'Exec=AppRun' 'Exec=${pname}'
      cp -r ${extracted}/usr/share/icons $out/share/
    '';
  };

  sb = pkgs.stdenv.mkDerivation {
    pname = "silverbullet-sb";
    inherit version;
    dontUnpack = true;
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib # libgcc_s.so.1
      pkgs.xz # liblzma.so.5
    ];
    installPhase = ''
      install -Dm755 ${extracted}/resources/app/sb $out/bin/sb
      wrapProgram $out/bin/sb \
        --set SB_ELECTRON_EXECUTABLE ${silverBullet}/bin/silverbullet
    '';
  };

in
{
  options.rzi.notes.enable = lib.mkEnableOption "Notes & knowledge management (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = [
      silverBullet
      sb
    ];
    # xdg.desktopEntries.silverbullet = {
    #   name = "SilverBullet";
    #   exec = "${silverBullet}/bin/silverbullet";
    #   icon = "silverbullet";
    #   comment = "Your #Programmable Personal Knowledge Database";
    #   categories = [
    #     "Office"
    #     "Utility"
    #   ];
    # };
  };
}
