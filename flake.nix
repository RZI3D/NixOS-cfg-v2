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
      };
    in
    result;
}
