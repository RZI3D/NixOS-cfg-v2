{
  lib,
  pkgs,
  ...
}:

pkgs.buildRustPackage rec {
  pname = "earctl";
  version = "0.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "DaanHessen";
    repo = "earctl";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # replace after first build
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # replace after first build

  nativeBuildInputs = [ pkgs.pkg-config ];

  buildInputs = [ pkgs.dbus ];

  # Runtime tools used by the CLI/server (bluetoothctl + sdptool)
  # Put them in PATH or wrap the binary if you prefer
  postInstall = ''
    # Optional: install the systemd user unit that ships with the project
    install -Dm644 ${src}/earctl.service $out/lib/systemd/user/earctl.service
  '';

  meta = with lib; {
    description = "Unofficial Rust API/CLI to control Nothing earbuds over the network";
    homepage = "https://github.com/DaanHessen/earctl";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "earctl";
  };
}
