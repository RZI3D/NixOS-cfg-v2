{ self, inputs, ... }:
{

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.zackariyyasattaur = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
    };
    modules = [
      self.homeModules.zackariyyasattaurModule
      nixpkgs.overlays = [
        inputs.nix4vscode.overlays.default
        inputs.dolphin-overlay.overlays.default
        (final: prev: {
          qt6Packages = prev.qt6Packages // {
            qt6ct = prev.callPackage "${self}/modules/pkgs/qt6ct-kde" { pkgs = prev; };
          };
        })
      ];
      {
        home.username = "zackariyyasattaur";
        home.homeDirectory = "/home/zackariyyasattaur";
      }
    ];
  };

  # This is your home.nix, your module where you configure home-manager
  # It's imported both in standalone configuration above, and in your nixos configuration
  flake.homeModules.zackariyyasattaurModule =
    { pkgs, ... }:
    {
      programs.bash = {
        enable = true;
        shellAliases = {
          ll = "ls -l";
        };
      };

      home.packages = [ pkgs.hello ];
      home.stateVersion = "24.11";
    };

}
