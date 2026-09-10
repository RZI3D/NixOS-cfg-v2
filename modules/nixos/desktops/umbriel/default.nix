{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.rzi.umbriel;
in
{
  options.rzi.umbriel.enable = lib.mkEnableOption "Umbriel WM (nixosModule)";

  imports = [ inputs.umbriel.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    programs.umbriel.enable = true;
  };
}
