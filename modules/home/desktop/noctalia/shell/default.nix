{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.noctalia.shell;
in
{
  options.rzi.noctalia.shell.enable = lib.mkEnableOption "Noctalia Shell (hmModule)";

  # imports = [ inputs.noctalia.homeModules.default ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {

      home.packages = with pkgs; [
        # For Screen Toolkit
        slurp
        grim
        hyprpicker
        tesseract
        imagemagick
        zbar
        curl
        jq
        bc
        mpv
        swappy
        satty
        translate-shell
        mpvpaper
        # For the gamelauncher
        clang # idk either man
      ];

      programs.noctalia = {
        enable = true;

        #         settings = { # This may also be a string or path to a .toml file.
        #           theme = {
        #             mode = "dark";
        #             source = "builtin";
        #             builtin = "Catppuccin";
        #           };
        #
        #           wallpaper = {
        #             enabled = true;
        #             default.path = "/path/to/wallpapers/wallpaper.png";
        #           };
        #         };

      };

    })
    (lib.mkIf config.rzi.umbriel.enable {
      # Setup Umbriel Noctalia config
      programs.umbriel.settings = {
        window_rule = [
          {
            match.app_id = "^dev.noctalia.Noctalia$";
            default_floating = true;
            default_size = [
              800
              1000
            ];
            blur_popups = false;
          }
          {
            match.title = "^notificationtoasts_.+_desktop";
            default_position = {
              x = 0;
              y = 0;
              anchor = "bottom_right";
            };
            default_focused = false;
            default_pinned = true;
          }
        ];

        keybinds = {
          # Core Noctalia
          "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
          "Mod+S" = "spawn:noctalia msg settings-toggle";
          "Alt+Tab" = "spawn:noctalia msg window-switcher";
          "Ctrl+Alt+V" = "spawn:noctalia msg panel-toggle clipboard";
          "Ctrl+Alt+Delete" = "spawn:noctalia msg panel-toggle session";
          "XF86PowerOff" = "spawn:noctalia msg panel-toggle session";

          # Audio & brightness (Noctalia)
          "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up";
          "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down";
          "XF86AudioMute" = "spawn:noctalia msg volume-mute";
          "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up";
          "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down";

          # Screenshots
          "Print" = "spawn:noctalia msg screenshot-region";
          "Ctrl+Print" = "spawn:noctalia msg screenshot-fullscreen";
          "Alt+Print" = "spawn:noctalia msg screenshot-window";
        };

      };
    })
  ];
}
