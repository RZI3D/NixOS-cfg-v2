{
  description = "OpenBubbles local build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          packages.openbubbles-app = pkgs.flutter.buildFlutterApplication {
            pname = "openbubbles-app";
            version = "1.15.0";

            src = ./src;

            autoPubspecLock = true;

            # Point to where the Rust code actually lives in the repo
            cargoRoot = "src-rust";
            cargoDeps = pkgs.rustPlatform.importCargoLock {
              lockFile = ./src/src-rust/Cargo.lock;
            };

            nativeBuildInputs = with pkgs; [
              pkg-config
              copyDesktopItems
              rustPlatform.cargoSetupHook
              rustPlatform.rust.cargo
              rustPlatform.rust.rustc
            ];

            buildInputs = with pkgs; [
              gtk3
              glib
              libsecret
              libxkbcommon
              webkitgtk_4_1
            ];
          };
          packages.default = self.packages.${pkgs.system}.openbubbles-app;
        };
    };
}
