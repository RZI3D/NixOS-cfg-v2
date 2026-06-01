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
      packages.obsAdvancedMasks = pkgs.stdenv.mkDerivation rec {
        pname = "obs-advanced-masks";
        version = "1.5.4";

        src = pkgs.fetchFromGitHub {
          owner = "FiniteSingularity";
          repo = "obs-advanced-masks";
          rev = "v${version}";
          hash = "sha256-42r7P70bshA36L+5Z2n+mG+ZgB7yI9Yshb12OQY4M6g=";
        };

        nativeBuildInputs = [
          pkgs.cmake
          pkgs.pkg-config
        ];

        buildInputs = [
          pkgs.obs-studio
        ];

        # Standard OBS plugin layout adjustment logic
        postInstall = ''
          mkdir -p $out/lib/obs-plugins
          mkdir -p $out/share/obs/obs-plugins/${pname}

          # Move compiled libraries from the generic bin/lib folders into position
          mv $out/bin/*.so $out/lib/obs-plugins/ 2>/dev/null || true
          mv $out/lib/*.so $out/lib/obs-plugins/ 2>/dev/null || true

          # Move runtime data/shaders into the correct OBS share hierarchy if they exist
          if [ -d "../data" ]; then
            cp -r ../data/* $out/share/obs/obs-plugins/${pname}/
          fi

          # Clean up unnecessary top-level directories created by default cmake install
          rm -rf $out/bin $out/obs-plugins $out/data $out/lib/cmake
        '';

        meta = with lib; {
          description = "Advanced Masks plugin for OBS Studio providing Alpha and Adjustment Masking";
          homepage = "https://github.com/FiniteSingularity/obs-advanced-masks";
          license = licenses.gpl2Only;
          platforms = pkgs.obs-studio.meta.platforms;
        };
      };
    };
  }
