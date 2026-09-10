{
  config,
  lib,
  pkgs,
  ...
}:
{
  # catppuccin.kitty.enable = true; # Should be handled by catppuccin.autoEnable
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = "11.0";
      cursor_trail = 1; # ms delay before trail triggers (0 = always, higher = only on big jumps)
      shell = "nu";
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
}
