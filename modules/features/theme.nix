{ self, inputs, ... }:
{

  # This is your module that imports and configures home-manager
  flake.homeModules.rziTheme =
    { pkgs, config, ... }:

    let
      colloid-catppuccin = pkgs.colloid-catppuccin; # Patched in overlays.nix, probaly dont need this?
      themeName = "Colloid-Dark-Catppuccin";
      kdeMochaLookAndFeel = pkgs.fetchzip {
        url = "https://github.com/catppuccin/kde/releases/download/v0.2.6/Mocha-color-schemes.tar.gz";
        sha256 = "sha256-I5WIXubfArLsrELLdWvuN66VsQ3dr7PzxYBlzz9qBBI=";
      };
    in

    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];

      # ── Packages ─────────────────────────────────────────────────────────────────
      home.packages = with pkgs; [
        # papirus-icon-theme # Handled by catppuccin, it patches it with your accent
        fish
        starship
        eza
        fzf
        zoxide
        # kdePackages.qtstyleplugin-kvantum # switched to qt6ct
        kdePackages.qtsvg
        libsForQt5.qt5ct
        # qt6Packages.qt6ct # has unfixed issues with kde, so i needed to patch it (see flake.nix)
        qt6ct-kde
      ];

      catppuccin.flavor = "mocha";
      catppuccin.accent = "sapphire";
      catppuccin.enable = true;

      # ── Kitty & terminal (Catppuccin via HM module) ────────────────────────────────
      catppuccin.kitty.enable = true;
      programs.kitty = {
        enable = true;
        settings = {
          font_family = "JetBrainsMono Nerd Font";
          font_size = "11.0";
          cursor_trail = 1; # ms delay before trail triggers (0 = always, higher = only on big jumps)
          shell = "fish";
          cursor_shape = "beam";
          window_padding_width = 12;
          background_opacity = "0.9";
          confirm_os_window_close = 0;
          auto_reload_config = 0;
        };
      };

      home.sessionVariables = {
        KITTY_WATCHER = "";
      };

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
        '';
        shellAliases = {
          clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
          ls = "eza --icons=always";
          pamcan = "pacman";
          q = "qs -c rzi kill; qs -c rzi";
          qd = "qs -c rzi kill; qs -c rzi -d";
          rswitch = "nh os switch ~/Programming/Linux/NixOS-cfg";
          mkdevenv = "devenv init; printf '#!/usr/bin/env bash\\n\\neval \"\$(devenv direnvrc)\"\\n\\n# You can pass flags to the devenv command\\n# For example: use devenv --impure --option services.postgres.enable:bool true\\nuse devenv\\n' > .envrc";
        };
      };

      programs.zoxide.enable = true;
      programs.zoxide.enableFishIntegration = true;
      programs.zoxide.enableBashIntegration = true;

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          add_newline = false;

          format = ''
            $time$cmd_duration 󰜥 $directory ''${custom.direnv} $git_branch
            $character'';

          character = {
            success_symbol = "[   ](bold fg:blue)";
            error_symbol = "[   ](bold fg:red)";
          };

          directory = {
            home_symbol = "  ";
            read_only = "  ";
            style = "bg:green fg:black";
            truncation_symbol = "…/";
            truncation_length = 6;
            fish_style_pwd_dir_length = 2;
            format = "[](bold fg:green)[󰉋 $path]($style)[](bold fg:green)";
            substitutions = {
              "Desktop" = "  ";
              "Documents" = "  ";
              "Downloads" = "  ";
              "Music" = " 󰎈 ";
              "Pictures" = "  ";
              "Videos" = "  ";
              "GitHub" = " 󰊤 ";
              "Programming" = " 󰨞 ";
              "Microcontrollers" = "  ";

            };
          };

          custom.direnv = {
            # Check if the DIRENV_DIR variable is set
            command = "echo $DIRENV_DIR";
            # Only show if the command output is not empty
            when = "test -n \"$DIRENV_DIR\"";
            shell = [
              "bash"
              "--norc"
              "--noprofile"
            ];
            format = "[](bold fg:bright-blue)[ ](bold bg:bright-blue fg:black)[! ](bold bg:bright-blue fg:bright-black)[](bold fg:bright-blue)";
          };

          git_branch = {
            style = "bg: cyan";
            symbol = "󰘬";
            format = "󰜥 [](bold fg:cyan)[$symbol $branch(:$remote_branch)](fg:black bg:cyan)[ ](bold fg:cyan)";
          };

          cmd_duration = {
            min_time = 0;
            format = "[](bold fg:yellow)[󰪢 $duration](bold bg:yellow fg:black)[](bold fg:yellow)";
          };

          time = {
            disabled = false; # Changed from true
            format = "[](bold fg:purple)[ $time](bg:purple fg:black)[](bold fg:purple) ";
            time_format = "%l:%M %p";
          };

          # Disable modules not used in this specific look
          package.disabled = true;
          memory_usage.disabled = true;
        };
      };

      # -- Helix --
      catppuccin.helix.enable = true;

      # ── GTK & QT theming ──────────────────────────────────────────────────────────────

      catppuccin.qt5ct.enable = false;
      catppuccin.kvantum.enable = false;
      qt = {
        style.package = with pkgs; [
          darkly
        ];
        enable = true;
        platformTheme.name = "qt6ct";
      };

      xdg.configFile."qt5ct/colors/catppuccin-mocha-sapphire.conf".text = ''
        [ColorScheme]
        active_colors=  #ffcdd6f4,     #ff45475a, #ff585b70, #ff313244, #ff11111b, #ff181825, #ffcdd6f4,     #ffcdd6f4,  #ffcdd6f4,     #ff1e1e2e, #ff181825, #ff11111b, #ff74c7ec, #ff11111b,    #ff89b4fa,     #ffb4befe,   #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff74c7ec
        inactive_colors=#ff7f849c, #ff1e1e2e,     #ff45475a, #ff313244, #ff11111b, #ff181825, #ff7f849c, #ffcdd6f4,  #ff7f849c, #ff1e1e2e, #ff181825, #ff11111b, #ff313244,              #ff7f849c, #ff7f849c, #ff7f849c,   #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff313244
        disabled_colors=#ff6c7086, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff6c7086, #ffcdd6f4,  #ff6c7086, #ff1e1e2e, #ff181825, #ff11111b, #ff181825,                #ff6c7086, #ffa9bcdb,   #ffc7cceb, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff181825
      '';

      xdg.configFile."qt6ct/colors/catppuccin-mocha-sapphire.conf".text = ''
        [ColorScheme]
        active_colors=  #ffcdd6f4,     #ff45475a, #ff585b70, #ff313244, #ff11111b, #ff181825, #ffcdd6f4,     #ffcdd6f4,  #ffcdd6f4,     #ff1e1e2e, #ff181825, #ff11111b, #ff74c7ec, #ff11111b,    #ff89b4fa,     #ffb4befe,   #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff74c7ec
        inactive_colors=#ff7f849c, #ff1e1e2e,     #ff45475a, #ff313244, #ff11111b, #ff181825, #ff7f849c, #ffcdd6f4,  #ff7f849c, #ff1e1e2e, #ff181825, #ff11111b, #ff313244,              #ff7f849c, #ff7f849c, #ff7f849c,   #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff313244
        disabled_colors=#ff6c7086, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff6c7086, #ffcdd6f4,  #ff6c7086, #ff1e1e2e, #ff181825, #ff11111b, #ff181825,                #ff6c7086, #ffa9bcdb,   #ffc7cceb, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff181825
      '';

      xdg.configFile."qt5ct/qt5ct.conf".text = ''
        [Appearance]
        color_scheme_path=${config.xdg.configHome}/qt5ct/colors/catppuccin-mocha-sapphire.conf
        custom_palette=true
        icon_theme=Papirus-Dark
        standard_dialogs=default
        style=Darkly
        [Fonts]
        general=JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0
        fixed=JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0
      '';

      xdg.configFile."qt6ct/qt6ct.conf".text = ''
        [Appearance]
        color_scheme_path=${config.xdg.configHome}/qt6ct/colors/catppuccin-mocha-sapphire.conf
        custom_palette=true
        icon_theme=Papirus-Dark
        standard_dialogs=default
        style=Darkly
        [Fonts]
        general=JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0
        fixed=JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0
      '';

      xdg.configFile."kdeglobals".text = ''
        [General]
        TerminalApplication=kitty
        TerminalService=kitty.desktop

        [ColorEffects:Disabled]
        ChangeSelectionColor=
        Color=30, 30, 46
        ColorAmount=0.30000000000000004
        ColorEffect=2
        ContrastAmount=0.1
        ContrastEffect=0
        Enable=
        IntensityAmount=-1
        IntensityEffect=0

        [ColorEffects:Inactive]
        ChangeSelectionColor=true
        Color=30, 30, 46
        ColorAmount=0.5
        ColorEffect=3
        ContrastAmount=0
        ContrastEffect=0
        Enable=true
        IntensityAmount=0
        IntensityEffect=0

        [Colors:Button]
        BackgroundAlternate=116,199,236
        BackgroundNormal=49, 50, 68
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=166, 173, 200
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=205, 214, 244
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [Colors:Complementary]
        BackgroundAlternate=17, 17, 27
        BackgroundNormal=24, 24, 37
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=166, 173, 200
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=205, 214, 244
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [Colors:Header]
        BackgroundAlternate=17, 17, 27
        BackgroundNormal=24, 24, 37
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=166, 173, 200
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=205, 214, 244
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [Colors:Selection]
        BackgroundAlternate=116,199,236
        BackgroundNormal=116,199,236
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=24, 24, 37
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=17, 17, 27
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [Colors:Tooltip]
        BackgroundAlternate=27,25,35
        BackgroundNormal=30, 30, 46
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=166, 173, 200
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=205, 214, 244
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [Colors:View]
        BackgroundAlternate=24, 24, 37
        BackgroundNormal=30, 30, 46
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=166, 173, 200
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=205, 214, 244
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [Colors:Window]
        BackgroundAlternate=17, 17, 27
        BackgroundNormal=24, 24, 37
        DecorationFocus=116,199,236
        DecorationHover=49, 50, 68
        ForegroundActive=250, 179, 135
        ForegroundInactive=166, 173, 200
        ForegroundLink=116,199,236
        ForegroundNegative=243, 139, 168
        ForegroundNeutral=249, 226, 175
        ForegroundNormal=205, 214, 244
        ForegroundPositive=166, 227, 161
        ForegroundVisited=203, 166, 247

        [General]
        ColorScheme=CatppuccinMochaSapphire

        [KDE]
        contrast=4
        frameContrast=0.2

        [WM]
        activeBackground=30,30,46
        activeBlend=205,214,244
        activeForeground=205,214,244
        inactiveBackground=17,17,27
        inactiveBlend=166,173,200
        inactiveForeground=166,173,200


        [Icons]
        Theme=Papirus-Dark
      '';

      xdg.dataFile."color-schemes/CatppuccinMochaSapphire.colors".source =
        "${kdeMochaLookAndFeel}/CatppuccinMochaSapphire.colors";

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Colloid-Dark-Catppuccin";
        };
      };

      # GTK
      gtk = {
        enable = true;
        theme = {
          name = themeName;
          package = colloid-catppuccin;
        };
      };

      xdg.configFile = {
        "gtk-4.0/gtk.css".source = "${colloid-catppuccin}/share/themes/${themeName}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source =
          "${colloid-catppuccin}/share/themes/${themeName}/gtk-4.0/gtk-dark.css";
        "gtk-4.0/assets" = {
          recursive = true;
          source = "${colloid-catppuccin}/share/themes/${themeName}/gtk-4.0/assets";
        };
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        videos = "${config.home.homeDirectory}/Videos";
        templates = "${config.home.homeDirectory}/Templates";
        publicShare = "${config.home.homeDirectory}/Public";
      };

      # gtk.iconTheme = {
      #   name = "Papirus-Dark";
      #   package = pkgs.papirus-icon-theme;
      # };

      gtk.gtk4.theme = config.gtk.theme;
      catppuccin.firefox.enable = true;

    };

}
