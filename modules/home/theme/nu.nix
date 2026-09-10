{
  config,
  lib,
  pkgs,
  ...
}:
{

  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      completions = {
        external = {
          enable = true;
          max_results = 200;
        };
      };
    };

    extraConfig = ''
      $env.config = ($env.config | upsert hooks {
        pre_prompt: [{ ||
          direnv export json | from json | default {} | load-env
        }]
      })

      def rswitch [] { nh os switch ~/Programming/Linux/NixOS-cfg }
      def rswitch-mac-pro [] { nh os switch ~/Programming/Linux/NixOS-cfg/.#rzi-mac-pro --target-host root@rzi-mac-pro; cvlc --play-and-exit ~/Music/SFX/outcome-success.ogg }
      def l [path = .] { ls $path | sort-by type name | table --icons -i false }
      def la [path = .] { ls -a $path | sort-by type name | table --icons -i false }
      def lt [path = .] { eza --tree $path }
      def ns [] { ^${lib.getExe pkgs.nix-search-tv} print | fzf --preview '${lib.getExe pkgs.nix-search-tv} preview {}' --scheme history | str trim }
      def p [prompt] { ${lib.getExe pkgs.gum} spin --spinner dot --title "Thinking..." --show-output -- pi --no-extensions -p $prompt | , mdcat -}

      if ($nu.is-interactive) and not ($env.SKIP_MICROFETCH? | default false | into bool) {
          ^${lib.getExe pkgs.microfetch}
      }
    '';
    extraEnv = ''
      $env.EDITOR = "hx"
      $env.config.buffer_editor = "hx"
      $env.CARAPACE_BRIDGES = "fish,inshellisense"
    '';
  };

}
