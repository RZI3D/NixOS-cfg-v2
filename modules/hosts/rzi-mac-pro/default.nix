{ self, inputs, ... }:
{
  # Regular system config
  flake.nixosConfigurations.rzi-mac-pro = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ self.nixosModules.rziMacProConfiguration ];
  };
}
