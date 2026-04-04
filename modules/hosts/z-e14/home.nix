{ self, inputs, ... }:
{

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.zackariyyasattaur = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
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
