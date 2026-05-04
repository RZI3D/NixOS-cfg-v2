{ inputs, self, ... }:
{
  perSystem = { config, pkgs, system, ... }: {
    packages.offline-repo = pkgs.symlinkJoin {
      name = "offline-repo-bundle";
      paths = [
        # Automatically pull the full system for your specific hosts
        self.nixosConfigurations.z-e14.config.system.build.toplevel
        self.nixosConfigurations.rzi-mac-pro.config.system.build.toplevel
        
        # Add the installer ISO dependencies if you use a specific one
        inputs.nixpkgs.legacyPackages.${system}.nixos-install-tools
      ];
    };
  };
}
