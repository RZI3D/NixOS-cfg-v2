{ self, inputs, ... }:
{

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.zackariyyasattaur = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      extraSpecialArgs = { inherit inputs; };

      overlays = [
        inputs.nix4vscode.overlays.default
        self.overlays.patched-pkgs
      ];

    };
    modules = [
      self.homeModules.zackariyyasattaurModule

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
      imports = with self.homeModules; [

        rziTheme

        ffWebApps
        browsers
        productivityCommon
        communication
        creativity
        notes
        office
        devtoolsCommon
        godot
        games
        creative3d
      ];

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
