{ lib, pkgs, ... }:
let
  svg_to_gcode = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "svg_to_gcode";
    version = "1.5.4";
    format = "wheel";

    src = pkgs.fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-MXI3z8urBpnDt1pT6w0b8MzGG6RplvKl52OnkCyzUMU=";
    };

    doCheck = false;
  };

  plotterPython = pkgs.python3.withPackages (ps: [
    svg_to_gcode
    ps.inkex
  ]);
in
pkgs.stdenv.mkDerivation {
  pname = "rzi-inkscape-plotter-tools";
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

  meta = with lib; {
    description = "Inkscape extension optimized for pen plotters";
    homepage = "https://github.com/RZItech/RZI-Inkscape-PlotterTools";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}