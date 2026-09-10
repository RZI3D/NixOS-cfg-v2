{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = false;

      format = ''
        $time$cmd_duration 󰜥 $username$hostname ''${custom.ssh}$directory ''${custom.direnv}$git_branch
        $character'';

      username = {
        style_user = "bg:blue fg:black";
        style_root = "bg:red fg:black";
        format = "[](bold fg:blue)[$user]($style)";
        show_always = true;
      };

      hostname = {
        ssh_only = false;
        style = "bg:blue fg:black";
        format = "[@$hostname]($style)[](bold fg:blue)";
      };

      custom.ssh = {
        when = "test -n \"$SSH_CONNECTION\" -o -n \"$SSH_CLIENT\" -o -n \"$SSH_TTY\"";
        shell = [
          "bash"
          "--norc"
          "--noprofile"
        ];
        format = "[](bold fg:bright-blue)[SSH](bold bg:bright-blue fg:black)[](bold fg:bright-blue) ";
      };

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
        format = "[](bold fg:bright-blue)[ ](bold bg:bright-blue fg:black)[! ](bold bg:bright-blue fg:bright-black)[ ](bold fg:bright-blue)";
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

}
