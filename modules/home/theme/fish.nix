{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      ls = "eza --icons=always";
      q = "qs -c rzi kill; qs -c rzi";
      qd = "qs -c rzi kill; qs -c rzi -d";
      rswitch = "nh os switch ~/Programming/Linux/NixOS-cfg";
      mkdevenv = "devenv init; printf '#!/usr/bin/env bash\\n\\neval \"\$(devenv direnvrc)\"\\n\\n# You can pass flags to the devenv command\\n# For example: use devenv --impure --option services.postgres.enable:bool true\\nuse devenv\\n' > .envrc";
    };
  };
}
