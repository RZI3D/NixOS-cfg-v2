{ inputs, ... }: final: prev: {
  helium = inputs.helium-flake.packages.${prev.system}.helium;
}