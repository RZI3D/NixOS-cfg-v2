{ self, inputs, ... }:
{
  flake.nixosModules.rziNiri =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.rzi-niri;
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let

      niriVOutPR = pkgs.callPackage ../../../../pkgs/niri-pr-vout.nix { };

      pkgs' = pkgs.extend inputs.dolphin-overlay.overlays.default;

    in
    {
      packages.rzi-niri = inputs.wrapper-modules.wrappers.niri.wrap {
        pkgs = pkgs';
        # package = niriVOutPR; #TODO: Re enable when i fix the niri-vout pkg

        settings = {

          prefer-no-csd = true; # Disable Window Decorations for GTK apps, since they look bad in niri (at least in my opinion).

          spawn-at-startup = [
            (lib.getExe self'.packages.rziNoctalia)
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          outputs."eDP-1" = {
            mode = "1920x1080@60.00";
            scale = 1.0;
          };

          input = {
            keyboard.xkb.layout = "us";

            touchpad = {
              tap = { };
              natural-scroll = { };
            };

          };

          layout = {
            gaps = 5;

            border = {
              width = 2;
              inactive-color = "#313244";
              active-color = "#74c7ec";
            };

            focus-ring = {
              off = { };
            };
          };

          window-rules = [
            {
              geometry-corner-radius = 12;
              clip-to-geometry = true;
              open-maximized = true;
              background-effect = {
                blur = true;
              };
            }
            {
              matches = [
                {
                  app-id = "^steam$";
                  title = "^Steam Big Picture Mode$";
                }
              ];
              open-fullscreen = true;
            }
            {
              # Fixes Vibrancy VScode
              matches = [
                {
                  app-id = "^[C-c]ode$";
                }
              ];

              draw-border-with-background = false;
            }
          ];

          switch-events = {"lid-close".spawn = "${lib.getExe self'.packages.rziNoctalia} ipc call sessionMenu lock";};

          binds = {
            "Mod+Return".spawn = [ (lib.getExe pkgs.kitty) ];

            "Mod+E".spawn = [ (lib.getExe' pkgs'.kdePackages.dolphin "dolphin") ];
            "Mod+S".spawn-sh = "${lib.getExe self'.packages.rziNoctalia} ipc call launcher toggle";
            # "Mod+Super_L".spawn-sh = "${lib.getExe self'.packages.rziNoctalia} ipc call launcher toggle";

            # The following was converted from the default config.kdl by Grok
            # Media keys (flat spawn-sh like vimjoyer)
            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "XF86AudioPlay".spawn-sh = "playerctl play-pause";
            "XF86AudioStop".spawn-sh = "playerctl stop";
            "XF86AudioPrev".spawn-sh = "playerctl previous";
            "XF86AudioNext".spawn-sh = "playerctl next";

            # Brightness (spawn list style)
            "XF86MonBrightnessUp".spawn = [
              "brightnessctl"
              "--class=backlight"
              "set"
              "+10%"
            ];
            "XF86MonBrightnessDown".spawn = [
              "brightnessctl"
              "--class=backlight"
              "set"
              "10%-"
            ];

            # General
            "Mod+O"."toggle-overview" = { };
            "Mod+Q"."close-window" = { };
            "Mod+Escape"."toggle-keyboard-shortcuts-inhibit" = { };

            "Mod+Shift+E".quit = { };
            "Ctrl+Alt+Delete".quit = { };

            # Navigation
            "Mod+Left"."focus-column-left" = { };
            "Mod+Down"."focus-window-down" = { };
            "Mod+Up"."focus-window-up" = { };
            "Mod+Right"."focus-column-right" = { };

            "Mod+H"."focus-column-left" = { };
            "Mod+J"."focus-window-down" = { };
            "Mod+K"."focus-window-up" = { };
            "Mod+L"."focus-column-right" = { };

            "Mod+Ctrl+Left"."move-column-left" = { };
            "Mod+Ctrl+Down"."move-window-down" = { };
            "Mod+Ctrl+Up"."move-window-up" = { };
            "Mod+Ctrl+Right"."move-column-right" = { };

            "Mod+Ctrl+H"."move-column-left" = { };
            "Mod+Ctrl+J"."move-window-down" = { };
            "Mod+Ctrl+K"."move-window-up" = { };
            "Mod+Ctrl+L"."move-column-right" = { };

            "Mod+Home"."focus-column-first" = { };
            "Mod+End"."focus-column-last" = { };
            "Mod+Ctrl+Home"."move-column-to-first" = { };
            "Mod+Ctrl+End"."move-column-to-last" = { };

            # Monitor
            "Mod+Shift+Left"."focus-monitor-left" = { };
            "Mod+Shift+Down"."focus-monitor-down" = { };
            "Mod+Shift+Up"."focus-monitor-up" = { };
            "Mod+Shift+Right"."focus-monitor-right" = { };

            "Mod+Shift+Ctrl+Left"."move-column-to-monitor-left" = { };
            "Mod+Shift+Ctrl+Down"."move-column-to-monitor-down" = { };
            "Mod+Shift+Ctrl+Up"."move-column-to-monitor-up" = { };
            "Mod+Shift+Ctrl+Right"."move-column-to-monitor-right" = { };

            # Workspace navigation
            "Mod+Page_Down"."focus-workspace-down" = { };
            "Mod+Page_Up"."focus-workspace-up" = { };
            "Mod+U"."focus-workspace-down" = { };
            "Mod+I"."focus-workspace-up" = { };

            "Mod+Ctrl+Page_Down"."move-column-to-workspace-down" = { };
            "Mod+Ctrl+Page_Up"."move-column-to-workspace-up" = { };
            "Mod+Ctrl+U"."move-column-to-workspace-down" = { };
            "Mod+Ctrl+I"."move-column-to-workspace-up" = { };

            "Mod+Shift+Page_Down"."move-workspace-down" = { };
            "Mod+Shift+Page_Up"."move-workspace-up" = { };
            "Mod+Shift+U"."move-workspace-down" = { };
            "Mod+Shift+I"."move-workspace-up" = { };

            # Wheel (simplified, no cooldown)
            "Mod+WheelScrollDown"."focus-workspace-down" = { };
            "Mod+WheelScrollUp"."focus-workspace-up" = { };
            "Mod+Ctrl+WheelScrollDown"."move-column-to-workspace-down" = { };
            "Mod+Ctrl+WheelScrollUp"."move-column-to-workspace-up" = { };

            "Mod+WheelScrollRight"."focus-column-right" = { };
            "Mod+WheelScrollLeft"."focus-column-left" = { };
            "Mod+Ctrl+WheelScrollRight"."move-column-right" = { };
            "Mod+Ctrl+WheelScrollLeft"."move-column-left" = { };

            "Mod+Shift+WheelScrollDown"."focus-column-right" = { };
            "Mod+Shift+WheelScrollUp"."focus-column-left" = { };

            # Workspace numbers
            "Mod+1"."focus-workspace" = 1;
            "Mod+2"."focus-workspace" = 2;
            "Mod+3"."focus-workspace" = 3;
            "Mod+4"."focus-workspace" = 4;
            "Mod+5"."focus-workspace" = 5;
            "Mod+6"."focus-workspace" = 6;
            "Mod+7"."focus-workspace" = 7;
            "Mod+8"."focus-workspace" = 8;
            "Mod+9"."focus-workspace" = 9;

            "Mod+Ctrl+1"."move-column-to-workspace" = 1;
            "Mod+Ctrl+2"."move-column-to-workspace" = 2;
            "Mod+Ctrl+3"."move-column-to-workspace" = 3;
            "Mod+Ctrl+4"."move-column-to-workspace" = 4;
            "Mod+Ctrl+5"."move-column-to-workspace" = 5;
            "Mod+Ctrl+6"."move-column-to-workspace" = 6;
            "Mod+Ctrl+7"."move-column-to-workspace" = 7;
            "Mod+Ctrl+8"."move-column-to-workspace" = 8;
            "Mod+Ctrl+9"."move-column-to-workspace" = 9;

            # Layout & sizing
            "Mod+BracketLeft"."consume-or-expel-window-left" = { };
            "Mod+BracketRight"."consume-or-expel-window-right" = { };
            #"Mod+Comma"."consume-window-into-column" = { };
            "Mod+Period"."expel-window-from-column" = { };

            "Mod+R"."switch-preset-column-width" = { };
            "Mod+Shift+R"."switch-preset-window-height" = { };
            "Mod+Ctrl+R"."reset-window-height" = { };

            "Mod+F"."maximize-column" = { };
            "Mod+Shift+F"."fullscreen-window" = { };
            "Mod+Ctrl+F"."maximize-window-to-edges" = { };

            "Mod+C"."center-column" = { };
            "Mod+Ctrl+C"."center-visible-columns" = { };

            "Mod+Minus".set-column-width = "-10%";
            "Mod+Equal".set-column-width = "+10%";
            "Mod+Shift+Minus".set-window-height = "-10%";
            "Mod+Shift+Equal".set-window-height = "+10%";

            "Mod+V"."toggle-window-floating" = { };
            "Mod+Shift+V"."switch-focus-between-floating-and-tiling" = { };
            "Mod+W"."toggle-column-tabbed-display" = { };

            # Screenshots
            "Print".screenshot = { };
            "Ctrl+Print"."screenshot-screen" = { };
            "Alt+Print"."screenshot-window" = { };
          };
        };
      };
    };
}
