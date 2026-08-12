{
  description = "NixOS Roro Style";

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
      importTree =
        dir:
        let
          inherit (tackInputs.nixpkgs) lib;
          files = map toString (lib.filesystem.listFilesRecursive dir);
        in
        {
          imports = builtins.filter (p: lib.hasSuffix ".nix" p && !(lib.hasInfix "/_" p)) files;
        };

      result = inputs.flake-parts.lib.mkFlake { inherit inputs; } (importTree ./modules);
    in
    result;
}
