{ self, inputs, ... }:
{
  # Regular system config
  flake.nixosConfigurations.rzi-mac-pro = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.rziMacProConfiguration ];
  };

  # ISO for offline install
  flake.nixosConfigurations.rzi-mac-pro-iso = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      self.nixosModules.rziMacProConfiguration
    ];
  };
}
