{ self, inputs, ... }:
{

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.zackariyyasattaurE14 = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      extraSpecialArgs = { inherit inputs; };

      overlays = [
        inputs.nix4vscode.overlays.default
        self.overlays.patched-pkgs
        inputs.dolphin-overlay.overlays.default
      ];

    };
    modules = [
      self.homeModules.zackariyyasattaurModuleE14

      {
        home.username = "zackariyyasattaur";
        home.homeDirectory = "/home/zackariyyasattaur";
      }
    ];
  };

  # This is your home.nix, your module where you configure home-manager
  # It's imported both in standalone configuration above, and in your nixos configuration
  flake.homeModules.zackariyyasattaurModuleE14 =
    { pkgs, ... }:
    {
      imports = with self.homeModules; [

        rziTheme
        inputs.spicetify-nix.homeManagerModules.default

        #ffWebApps
        browsers
        productivityCommon
        communication
        creativity
        notes
        office
        devtoolsCommon
        microcontrollerDev
        godot
        games
        creative3d
        recording
        media
        drone
      ];
      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
      home.packages = [ pkgs.hello ];
      home.stateVersion = "26.05";
    };

}
