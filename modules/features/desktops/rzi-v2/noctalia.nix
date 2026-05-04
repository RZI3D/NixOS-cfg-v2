{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.rziNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!

        # For plugins:
        extraPackages = with pkgs; [
          grim
          slurp
          wl-clipboard
          tesseract
          imagemagick
          zbar
          curl
          translate-shell
          wl-screenrec
          ffmpeg
          gifski
          evtest
          qt6.qtwebsockets
        ];

        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
      };
    };
}
