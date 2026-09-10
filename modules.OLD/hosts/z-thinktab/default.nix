{ self, inputs, ... }:
{
  flake.nixosConfigurations.z-thinktab = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.z-thinktabConfiguration
    ];
  };
}
