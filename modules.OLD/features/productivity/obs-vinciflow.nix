{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.vinciFlow = pkgs.stdenv.mkDerivation rec {
        pname = "vinci-flow";
        version = "3.7.0";

        src = pkgs.fetchFromGitHub {
          owner = "mmlTools";
          repo = "vinci-flow";
          rev = version;
          hash = "sha256-ekwL//QtMnyiVNxmrjh92xmLRpioG95coCjVEwZcCyo=";
        };

        nativeBuildInputs = [
          pkgs.cmake
          pkgs.pkg-config
          pkgs.qt6.wrapQtAppsHook
        ];

        buildInputs = [
          pkgs.obs-studio
          pkgs.qt6.qtbase
          pkgs.qt6.qtsvg
        ];

        # Standard OBS plugin layout logic
        postInstall = ''
          mkdir -p $out/lib/obs-plugins
          mkdir -p $out/share/obs/obs-plugins/${pname}

          # Move the compiled library to the plugins folder
          mv $out/bin/*.so $out/lib/obs-plugins/ 2>/dev/null || true

          # VinciFlow needs its 'data' folder for HTML templates
          if [ -d "../data" ]; then
            cp -r ../data/* $out/share/obs/obs-plugins/${pname}/
          fi

          # Clean up unnecessary folders created by default cmake install
          rm -rf $out/bin $out/obs-plugins $out/data
        '';

        meta = with lib; {
          description = "VinciFlow: Smart Lower Thirds Orchestration for OBS Studio";
          homepage = "https://github.com/mmlTools/vinci-flow";
          license = licenses.gpl2Only;
          platforms = pkgs.obs-studio.meta.platforms;
        };
      };
    };
}
