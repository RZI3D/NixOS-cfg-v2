{
  self,
  inputs,
  ...
}:
{
  flake.homeModules.notes =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        logseq
      ];
    };
}
