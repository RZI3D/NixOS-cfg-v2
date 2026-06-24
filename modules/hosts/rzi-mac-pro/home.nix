{ self, inputs, ... }:
{

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.rzi = inputs.home-manager.lib.homeManagerConfiguration {
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
      self.homeModules.rziModule

      {
        home.username = "rzi";
        home.homeDirectory = "/home/rzi";
      }
    ];
  };

  # This is your home.nix, your module where you configure home-manager
  # It's imported both in standalone configuration above, and in your nixos configuration
  flake.homeModules.rziModule =
    { pkgs, ... }:
    {
      imports = with self.homeModules; [

        rziTheme
        inputs.sops-nix.homeManagerModules.sops
        podmanStacks
        #         inputs.spicetify-nix.homeManagerModules.default
        #
        #         ffWebApps
        #         browsers
        #         productivityCommon
        #         communication
        #         creativity
        #         notes
        #         office
        #         devtoolsCommon
        #         microcontrollerDev
        #         godot
                 games
        #         creative3d
        #         media
      ];

      sops = {
        defaultSopsFile = ../../../secrets/rzi-mac-pro/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/rzi/.config/sops/age/keys.txt";
        secrets = {
          "grimmory/db_user_password" = {};
          "grimmory/db_root_password" = {};
        };
      };

      programs.bash = {
        enable = true;
        shellAliases = {
          ll = "ls -l";
        };
      };

      home.packages = [ pkgs.hello ];
      home.stateVersion = "26.05";
    };

}
