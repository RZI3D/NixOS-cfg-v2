{ self, inputs, ... }:
{
  flake.nixosConfigurations.z-e14 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.z-e14Configuration
    ];
  };
}
