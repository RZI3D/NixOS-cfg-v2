{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  flake.homeModules.umbriel =
    { pkgs, ... }:
    {
      imports = [ inputs.umbriel.homeModules.default ];
      home.packages = with pkgs; [
        pkgs.bibata-cursors
      ];
      programs.umbriel = {
        enable = true;
        settings = {

          general.autostart = [
            (lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default)
          ];

          layout.gap = 5;

          animation.windows_in = {
            enabled = true;
            duration_ms = 150;
            curve = "easeout";
            style = "popin"; # "popin", "zoom", "slide", "fade", or "none"
            scale = 0.2; # 0.1-1.0, used by "popin"
          };

          animation.windows_out = {
            enabled = true;
            duration_ms = 150;
            curve = "easein";
            style = "slide"; # "fade" or "slide"
          };

          window_rule = [
            {
              blur = true;
              blur_optimized = true;
            }
            {
              match.app_id = "^(Emulator|zenity|xdg-desktop-portal|qalculate-gtk|org\\.pulseaudio\\.pavucontrol)$";
              default_floating = true;
            }
            {
              match.is_focused = false;
              opacity = 0.85;
            }
            {
              match.is_focused = true;
              opacity = 1.0;
            }
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
              match.app_id = "^dev.noctalia.UmbrielSharePicker$";
              default_floating = true;
              default_size = [
                800
                600
              ];
              default_position = {
                x = 32;
                y = 32;
                anchor = "bottom_right";
              };
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

          input = {
            keyboard.layout = "us";
            touchpad.natural_scroll = true;
            cursor.theme = "Bibata-Modern-Ice";
          };

          keybinds = {
            # Launchers / apps
            "Mod" = "overview-toggle";
            "Mod+Return" = "spawn:${lib.getExe pkgs.kitty}";
            "Mod+E" = "spawn:${lib.getExe' pkgs.kdePackages.dolphin "dolphin"}";

            # Core Noctalia
            "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
            "Mod+S" = "spawn:noctalia msg settings-toggle";
            "Alt+Tab" = "spawn:noctalia msg window-switcher";
            "Ctrl+Alt+V" = "spawn:noctalia msg panel-toggle clipboard";
            "Ctrl+Alt+Delete" = "spawn:noctalia msg panel-toggle session";

            # Audio & brightness (Noctalia)
            "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up";
            "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down";
            "XF86AudioMute" = "spawn:noctalia msg volume-mute";
            "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up";
            "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down";

            # Extra media
            "XF86AudioMicMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "XF86AudioPlay" = "spawn:playerctl play-pause";
            "XF86AudioStop" = "spawn:playerctl stop";
            "XF86AudioPrev" = "spawn:playerctl previous";
            "XF86AudioNext" = "spawn:playerctl next";

            # General
            "Mod+O" = "overview-toggle";
            "Mod+Q" = "window-close";
            "Mod+Shift+E" = "session-quit";

            # Navigation (focus)
            "Mod+Left" = "window-focus-left";
            "Mod+Down" = "window-focus-down";
            "Mod+Up" = "window-focus-up";
            "Mod+Right" = "window-focus-right";

            "Mod+H" = "window-focus-left";
            "Mod+J" = "window-focus-down";
            "Mod+K" = "window-focus-up";
            "Mod+L" = "window-focus-right";

            # Move column / window
            "Mod+Ctrl+Left" = "column-move-left";
            "Mod+Ctrl+Down" = "window-move-down";
            "Mod+Ctrl+Up" = "window-move-up";
            "Mod+Ctrl+Right" = "column-move-right";

            "Mod+Ctrl+H" = "column-move-left";
            "Mod+Ctrl+J" = "window-move-down";
            "Mod+Ctrl+K" = "window-move-up";
            "Mod+Ctrl+L" = "column-move-right";

            "Mod+Home" = "column-focus-first";
            "Mod+End" = "column-focus-last";
            "Mod+Ctrl+Home" = "column-move-to-first";
            "Mod+Ctrl+End" = "column-move-to-last";

            # Monitor focus / move
            "Mod+Shift+Left" = "output-focus-left";
            "Mod+Shift+Down" = "output-focus-down";
            "Mod+Shift+Up" = "output-focus-up";
            "Mod+Shift+Right" = "output-focus-right";

            "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
            "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";
            "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
            "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";

            # Workspace navigation
            "Mod+Page_Down" = "workspace-next";
            "Mod+Page_Up" = "workspace-previous";
            "Mod+U" = "workspace-next";
            "Mod+I" = "workspace-previous";

            "Mod+Ctrl+Page_Down" = "column-move-to-workspace-next";
            "Mod+Ctrl+Page_Up" = "column-move-to-workspace-previous";
            "Mod+Ctrl+U" = "column-move-to-workspace-next";
            "Mod+Ctrl+I" = "column-move-to-workspace-previous";

            "Mod+Shift+Page_Down" = "workspace-move-down";
            "Mod+Shift+Page_Up" = "workspace-move-up";
            "Mod+Shift+U" = "workspace-move-down";
            "Mod+Shift+I" = "workspace-move-up";

            # Wheel

            "Mod+WheelDown" = "workspace-next";
            "Mod+WheelUp" = "workspace-previous";
            "Mod+Ctrl+WheelDown" = "column-move-to-workspace-next";
            "Mod+Ctrl+WheelUp" = "column-move-to-workspace-previous";

            "Mod+WheelRight" = "window-focus-right";
            "Mod+WheelLeft" = "window-focus-left";
            "Mod+Ctrl+WheelRight" = "column-move-right";
            "Mod+Ctrl+WheelLeft" = "column-move-left";

            "Mod+Shift+WheelDown" = "window-focus-right";
            "Mod+Shift+WheelUp" = "window-focus-left";

            # Numbered workspaces
            "Mod+1" = "workspace-switch:1";
            "Mod+2" = "workspace-switch:2";
            "Mod+3" = "workspace-switch:3";
            "Mod+4" = "workspace-switch:4";
            "Mod+5" = "workspace-switch:5";
            "Mod+6" = "workspace-switch:6";
            "Mod+7" = "workspace-switch:7";
            "Mod+8" = "workspace-switch:8";
            "Mod+9" = "workspace-switch:9";

            "Mod+Ctrl+1" = "column-move-to-workspace:1";
            "Mod+Ctrl+2" = "column-move-to-workspace:2";
            "Mod+Ctrl+3" = "column-move-to-workspace:3";
            "Mod+Ctrl+4" = "column-move-to-workspace:4";
            "Mod+Ctrl+5" = "column-move-to-workspace:5";
            "Mod+Ctrl+6" = "column-move-to-workspace:6";
            "Mod+Ctrl+7" = "column-move-to-workspace:7";
            "Mod+Ctrl+8" = "column-move-to-workspace:8";
            "Mod+Ctrl+9" = "column-move-to-workspace:9";

            # Layout & sizing
            "Mod+BracketLeft" = "window-consume-left";
            "Mod+BracketRight" = "window-expel-right";
            "Mod+Period" = "window-expel-right";

            "Mod+R" = "window-cycle-width";
            "Mod+Shift+R" = "window-cycle-width-back";

            "Mod+F" = "window-toggle-maximize";
            "Mod+Shift+F" = "window-toggle-fullscreen";
            "Mod+Ctrl+F" = "window-toggle-maximize-to-edges";

            "Mod+C" = "column-center";

            "Mod+Minus" = "window-modify-width:-0.1";
            "Mod+equal" = "window-modify-width:+0.1";

            "Mod+V" = "window-toggle-floating";
            "Mod+Shift+V" = "window-focus-switch-floating";

            # Screenshots
            "Print" = "spawn:noctalia msg screenshot-region";
            "Ctrl+Print" = "spawn:noctalia msg screenshot-fullscreen";
            "Alt+Print" = "spawn:noctalia msg screenshot-window";
          };
        };
      };
    };

  flake.nixosModules.umbriel =
    { pkgs, ... }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];
      programs.umbriel.enable = true;
    };

}
