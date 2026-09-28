{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.rzi.productivity-common;

  # Applied locally on purpose: a global dolphin overlay wraps the package with
  # its `.dev` output, which drags the whole KDE dev closure onto every host
  # (e.g. the Plasma server rzi-mac-pro) even though the "Open with outside
  # KDE" fix is only relevant on the non-KDE desktops.
  pkgs' = pkgs.extend inputs.dolphin-overlay.overlays.default;
in
{
  options.rzi.productivity-common.enable = lib.mkEnableOption "Common productivity packages (nixosModule)";

  config = lib.mkIf cfg.enable {
    programs.superfile = {
      enable = true;
      metadataPackage = pkgs.exiftool;
      zoxidePackage = pkgs.zoxide;
      settings = {
        editor = "";
        dir_editor = "";
        auto_check_update = false;
        cd_on_quit = false;
        default_open_file_preview = true;
        show_image_preview = true;
        show_panel_footer_info = true;
        default_directory = ".";
        file_size_use_si = false;
        default_sort_type = 0; # 0 name, 1 size, 2 date, 3 type, 4 natural
        sort_order_reversed = false;
        case_sensitive_sort = false;
        shell_close_on_success = false;
        page_scroll_size = 0;
        debug = false;
        ignore_missing_fields = false;
        file_panel_extra_columns = 0;
        file_panel_name_percent = 50;

        theme = "catppuccin";
        code_previewer = "bat";
        nerdfont = true;
        show_select_icons = true;
        transparent_background = false;
        file_preview_width = 0;
        enable_file_preview_border = false;
        sidebar_width = 20;
        sidebar_sections = [
          "home"
          "pinned"
          "disks"
        ];

        border_top = "─";
        border_bottom = "─";
        border_left = "│";
        border_right = "│";
        border_top_left = "╭";
        border_top_right = "╮";
        border_bottom_left = "╰";
        border_bottom_right = "╯";
        border_middle_left = "├";
        border_middle_right = "┤";

        metadata = true;
        enable_md5_checksum = false;
        zoxide_support = true;
      };

      hotkeys = {
        confirm = [
          "enter"
          "right"
          "l"
        ];
        cd_quit = [
          "Q"
          ""
        ];
        quit = [
          "q"
          "esc"
        ];

        list_down = [
          "down"
          "j"
        ];
        list_up = [
          "up"
          "k"
        ];
        page_down = [
          "pgdown"
          ""
        ];
        page_up = [
          "pgup"
          ""
        ];

        close_file_panel = [
          "w"
          ""
        ];
        create_new_file_panel = [
          "n"
          ""
        ];
        next_file_panel = [
          "tab"
          "L"
        ];
        open_sort_options_menu = [
          "o"
          ""
        ];
        pinned_directory = [
          "P"
          ""
        ];
        previous_file_panel = [
          "shift+left"
          "H"
        ];
        split_file_panel = [
          "N"
          ""
        ];
        toggle_file_preview_panel = [
          "f"
          ""
        ];
        toggle_reverse_sort = [
          "R"
          ""
        ];

        focus_on_metadata = [
          "m"
          ""
        ];
        focus_on_process_bar = [
          "p"
          ""
        ];
        focus_on_sidebar = [
          "s"
          ""
        ];

        file_panel_item_create = [
          "ctrl+n"
          ""
        ];
        file_panel_item_rename = [
          "ctrl+r"
          ""
        ];

        copy_items = [
          "ctrl+c"
          ""
        ];
        cut_items = [
          "ctrl+x"
          ""
        ];
        delete_items = [
          "ctrl+d"
          "delete"
          ""
        ];
        paste_items = [
          "ctrl+v"
          "ctrl+w"
          ""
        ];
        permanently_delete_items = [
          "D"
          ""
        ];

        compress_file = [
          "ctrl+a"
          ""
        ];
        extract_file = [
          "ctrl+e"
          ""
        ];

        open_current_directory_with_editor = [
          "E"
          ""
        ];
        open_file_with_editor = [
          "e"
          ""
        ];

        change_panel_mode = [
          "v"
          ""
        ];
        copy_path = [
          "ctrl+p"
          ""
        ];
        copy_present_working_directory = [
          "c"
          ""
        ];
        open_command_line = [
          ":"
          ""
        ];
        open_help_menu = [
          "?"
          ""
        ];
        open_spf_prompt = [
          ">"
          ""
        ];
        open_zoxide = [
          "z"
          ""
        ];
        toggle_dot_file = [
          "."
          ""
        ];
        toggle_footer = [
          "F"
          ""
        ];

        confirm_typing = [
          "enter"
          ""
        ];
        cancel_typing = [
          "ctrl+c"
          "esc"
        ];

        parent_directory = [
          "h"
          "left"
          "backspace"
        ];
        search_bar = [
          "/"
          ""
        ];

        file_panel_select_mode_items_select_down = [
          "shift+down"
          "J"
        ];
        file_panel_select_mode_items_select_up = [
          "shift+up"
          "K"
        ];
        file_panel_select_all_items = [
          "A"
          ""
        ];
      };

    };
    home.packages = with pkgs; [
      pkgs'.kdePackages.dolphin
      exiftool # meeded by superfile metadatai
      bat
      kdePackages.ark
      motrix-next
      kdePackages.kate
      kdePackages.gwenview
      # yazi # superfile is better imo
      easyeffects
      kdePackages.filelight
      qalculate-gtk
      pavucontrol
    ];
  };
}
