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
      packages.weylus-ce = pkgs.weylus.overrideAttrs (oldAttrs: rec {
        pname = "weylus-ce";
        version = "2025.11.04";

        src = pkgs.fetchFromGitHub {
          owner = "electronstudio";
          repo = "WeylusCommunityEdition";
          rev = version;
          hash = "sha256-Brw1ObsHdxs/vluZ4MDiIE2KZEYgjSFNcXHOVFue08A="; # Replace with actual hash
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-va8DYVGP7laPtZlxO4NYemJmops1kAHeUbsl/oit7QU=";
        };

        cargoRoot = ".";

        # Ensure PipeWire and Wayland libs are available during build/runtime
        buildInputs = oldAttrs.buildInputs ++ [
          pkgs.pipewire
          pkgs.wayland
          pkgs.libxkbcommon
        ];
      });
    };

}
