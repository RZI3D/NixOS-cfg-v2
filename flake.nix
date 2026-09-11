{
  outputs =
    { self, ... }:
    let
      tackInputs = import ./.tack;
      inputs = tackInputs // {
        self = selfInherits;
      };
      selfInherits = result // {
        inherit inputs;
        inherit (self) outPath;
      };
      result = inputs.snowfall-lib.mkFlake {
        inherit inputs;
        src = ./.;
        snowfall.namespace = "rzi";
        channels-config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-39.8.10"
          ];
        };
        # Only x86_64-linux is supported. Without this, snowfall/flake-utils-plus
        # generate `packages.<system>` for the default system list (including
        # darwin), and nixpkgs 26.11 rejects x86_64-darwin at evaluation time.
        supportedSystems = [ "x86_64-linux" ];
      };
    in
    result;
}
