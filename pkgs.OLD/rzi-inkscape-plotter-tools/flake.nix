{
  description = "RZI Inkscape PlotterTools Extension";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python3 = pkgs.python3;

        # 1. Fetch the pre-compiled wheel directly from PyPI
        svg_to_gcode = python3.pkgs.buildPythonPackage rec {
          pname = "svg_to_gcode";
          version = "1.5.4";
          format = "wheel"; # Tell Nix this is already a built wheel!

          src = pkgs.fetchPypi {
            inherit pname version;
            # We explicitly target the .whl format instead of the source tarball
            format = "wheel";
            # You are using Python 3.13, so we grab the universal/pure python wheel
            dist = "py3";
            python = "py3";
            hash = "sha256-MXI3z8urBpnDt1pT6w0b8MzGG6RplvKl52OnkCyzUMU="; # Get the real hash of the .whl file
          };

          # Disabling checks since wheels don't contain unit tests
          doCheck = false;
        };

        plotterPython = python3.withPackages (ps: [
          svg_to_gcode
          ps.inkex
        ]);

      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "RZI-Inkscape-PlotterTools";
          version = "unstable";

          src = pkgs.fetchFromGitHub {
            owner = "RZItech";
            repo = "RZI-Inkscape-PlotterTools";
            rev = "master";
            hash = "sha256-m5iGaeZcZcSd7VTa7EDs5vL8e5QSaJD6LjGdEjoiq5o=";
          };

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            targetDir=$out/share/inkscape/extensions
            mkdir -p $targetDir
            cp -r * $targetDir/

            # Create the launch script inside the laser folder
            cat << 'EOF' > $targetDir/laser/launch-laser.sh
            #!/bin/sh
            cd "$(dirname "$0")" || exit 1
            exec ${plotterPython}/bin/python ./laser.py "$@"
            EOF
            chmod +x $targetDir/laser/launch-laser.sh

            # Swap the interpreter to shell
            if [ -f "$targetDir/laser/laser.inx" ]; then
              substituteInPlace "$targetDir/laser/laser.inx" \
                --replace-fail 'interpreter="python"' 'interpreter="shell"' \
                --replace-fail 'laser.py' 'launch-laser.sh'
            fi

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Inkscape extension optimized for pen plotters";
            homepage = "https://github.com/RZItech/RZI-Inkscape-PlotterTools";
            license = licenses.gpl3Plus;
            platforms = platforms.all;
          };
        };
      }
    );
}

