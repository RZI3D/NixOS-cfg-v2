{
  description = "OpenBubbles local build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # The trick from the Discourse thread:
    # Use git+file to ensure submodules are fetched for this specific path
    openbubbles-src = {
      url = "git+file:///mnt/DATA/Programming/Linux/NixOS-cfg/pkgs/openbubbles-app/src?submodules=1";
      flake = false;
    };
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
        {
          pkgs,
          config,
          inputs',
          ...
        }:
        {
          packages.openbubbles-app = pkgs.flutter.buildFlutterApplication {
            pname = "openbubbles-app";
            version = "1.15.0";

            # Access the input through 'inputs' which is available in this scope
            src = inputs.openbubbles-src;

            autoPubspecLock = true;

            # Point to where the Rust code lives inside that fetched source
            cargoRoot = "rust";
            cargoDeps = pkgs.rustPlatform.importCargoLock {
              # Use the store path from the fetched input
              lockFile = "${inputs.openbubbles-src}/rust/Cargo.lock";
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

          packages.default = config.packages.openbubbles-app;
        };
    };
}
