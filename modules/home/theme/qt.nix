{
  config,
  lib,
  pkgs,
  ...
}:
let
  kdeMochaLookAndFeel = pkgs.fetchzip {
    url = "https://github.com/catppuccin/kde/releases/download/v0.2.6/Mocha-color-schemes.tar.gz";
    sha256 = "sha256-I5WIXubfArLsrELLdWvuN66VsQ3dr7PzxYBlzz9qBBI=";
  };
in
{
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
}
