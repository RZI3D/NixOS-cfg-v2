{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        {
          pkgs,
          config,
          inputs',
          ...
        }:
        {
          packages.freyr-js = pkgs.buildNpmPackage rec {
            pname = "freyr";
            version = "0.10.3";

            src = pkgs.fetchFromGitHub {
              owner = "miraclx";
              repo = "freyr-js";
              rev = "v${version}";
              hash = "sha256-tAlY0wAjN1rP4MVPl40N/rgMQH08jD0XKBVRGFWAK70=";
            };

            # 1. Update this to version 2
            npmDepsFetcherVersion = 2;

            # 2. Reset this to force a re-calculation of ALL dependencies (axios, etc)
            npmDepsHash = "sha256-9lD87ikbcCf0DH4wbZU7RQA9ymKj+K+Ul0rhBsuFgO0=";

            # 3. Prevent Nix from looking for a 'build' script that doesn't exist
            dontNpmBuild = true;

            makeCacheWritable = true;
            npmFlags = [ "--legacy-peer-deps" ];

            nativeBuildInputs = [ pkgs.makeWrapper ];

            postInstall = ''
              wrapProgram $out/bin/freyr \
                --prefix PATH : ${
                  pkgs.lib.makeBinPath [
                    pkgs.ffmpeg-full
                    pkgs.yt-dlp
                    pkgs.atomicparsley
                  ]
                }
            '';
          };
          packages.default = config.packages.freyr-js;
        };
    };
}
