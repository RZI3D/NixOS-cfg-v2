{ inputs, ... }:
final: prev:
# Snowfall evaluates every overlay with a `fake-pkgs` set (no `lib.extend`)
# to decide whether it should be exported. nix-minecraft's overlay touches
# `pkgs.lib` eagerly, so short-circuit for the fake set and apply it for real.
if prev.isFakePkgs or false then
  { }
else
  inputs.nix-minecraft.overlays.default final prev
