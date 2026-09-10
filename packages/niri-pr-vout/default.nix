{ lib, pkgs, ... }:
let
  niri = pkgs.niri;
in
niri.overrideAttrs (finalAttrs: {
  version = "26.04-wip-vout";

  src = pkgs.fetchFromGitHub {
    owner = "willybarret";
    repo = "niri";
    rev = "wip/virtual-outputs";
    hash = "sha256-tcjX4u+lc90IE8HFVsYgVLLOLo/9DugHUizv3dh3tHQ=";
  };

  cargoHash = "sha256-gfnalA3qI3a9h3PvsxgQLCrzapfjLLkxhTMJpwRh+ro=";
})