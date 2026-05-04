{
  self,
  inputs,
  ...
}: {
  flake.homeModules.notes =
  {pkgs, ...}:
  let
    logseq-e39 = pkgs.logseq.override {
      electron = pkgs.electron_39;
    };
  in
  {
    home.packages = with pkgs; [
      #anytype
      logseq-e39
    ];
  };
}
