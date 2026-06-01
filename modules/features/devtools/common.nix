{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  flake.homeModules.devtoolsCommon =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gh
        helix
        htop
        nil # Nix Language Server
        nixfmt # Official Nix Formatter
        qt6.qtdeclarative
        kdePackages.qttools
        opencode
        nodejs # Most MCP servers require nodejs
        #kilocode-cli
      ];

      # Git Configuration
      programs.git = {
        enable = true;
        signing.format = null;
        settings = {
          user = {
            name = "rzi3d";
            email = "zackiesattaur@gmail.com";
          };
          init.defaultBranch = "main";

        };
      };

      # Helix Text Editor
      programs.helix = {
        enable = true;
        settings = {
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.nixfmt;
          }
        ];
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true; # This gives faster, cached Nix support (highly recommended)
        # silent = true; # Don't print direnv messages in the terminal
        config = {
          global = {
            log_filter = "^loading";
          };
        };
      };

      # 2. VSCode Configuration
      programs.vscode = {
        enable = true;
        profiles.default = {
          extensions = pkgs.nix4vscode.forVscode [
            # Bierner's Markdown Suite
            "bierner.color-info"
            "bierner.markdown-checkbox"
            "bierner.markdown-emoji"
            "bierner.markdown-footnotes"
            "bierner.markdown-mermaid"

            # Appearance & UI
            "catppuccin.catppuccin-vsc"
            "oderwat.indent-rainbow"
            "Gruntfuggly.todo-tree"

            # Languages & Tools
            "charliermarsh.ruff"
            "codezombiech.gitignore"
            "dart-code.dart-code"
            "dart-code.flutter"
            "geequlim.godot-tools"
            "redhat.vscode-yaml"
            "swiftlang.swift-vscode"
            "llvm-vs-code-extensions.lldb-dap"

            # Python Stack
            "ms-python.python"
            "ms-python.debugpy"
            "ms-python.vscode-pylance"
            "ms-python.vscode-python-envs"

            # Git & GitHub
            "donjayamanne.githistory"
            "mhutchie.git-graph"
            "github.codespaces"
            "github.remotehub"
            "github.vscode-github-actions"
            "github.vscode-pull-request-github"

            # AI & Remote
            "google.gemini-cli-vscode-ide-companion"
            # "kilocode.kilo-code" # WHAT is that v7 kilo? Ima try roo.
            "RooVeterinaryInc.roo-cline"
            "ms-azuretools.vscode-containers"
            "ms-vscode-remote.remote-containers"
            "ms-vscode.remote-explorer"
            "ms-vscode.remote-repositories"
            "ms-vscode.remote-server"
            "ms-vscode.vscode-github-issue-notebooks"
            "ms-vsliveshare.vsliveshare"

            # QT (Yessirrr)

            "TheQtCompany.qt-core" # required base for all others
            "TheQtCompany.qt-qml" # QML language support, Quickshell issues
            #             "TheQtCompany.qt-cpp" # Qt C++ support
            #             "TheQtCompany.qt-ui" # .ui file designer

            "jnoortheen.nix-ide" # Nix Syntax Highlighting

            "esbenp.prettier-vscode" # Formatting
            "alefragnani.Bookmarks"

            "dtoplak.vscode-glsllint"
            "slevesque.shader"

            "thijsdaniels.vscode-openscad-preview"
            "Leathong.openscad-language-support"
            "algoscienceacademy.qt-live-preview"
          ];
          userSettings = {
            "catppuccin.accentColor" = "sapphire";
            "editor.formatOnSave" = true;
            "editor.semanticHighlighting.enabled" = true;
            "password-store" = "kwallet6";
            "qt-qml.qmlls.additionalImportPaths" = [
              "${pkgs.quickshell}/lib/qml"
            ];
            "qt-qml.qmlls.customExePath" = "qmlls";
            "terminal.integrated.minimumContrastRatio" = 1;
            "window.titleBarStyle" = "custom";
            "workbench.colorTheme" = "Catppuccin Mocha";
            "workbench.iconTheme" = "catppuccin-mocha";
            "workbench.editorAssociations" = {
              "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.qrc" =
                "default";
              "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.ui" = "default";
              "*.qrc" = "qt-core.qrcEditor";
            };
            "qt-qml.doNotAskForQmllsDownload" = true;
            "kilo-code.debug" = false;
            "qt-qml.qmlls.enabled" = false;
            "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
            "terminal.integrated.commandsToSkipShell" = [
              "kilo-code.new.agentManagerOpen"
              "kilo-code.new.agentManager.showTerminal"
            ];
            "qtLivePreview.qmlEngine" = "/etc/profiles/per-user/zackariyyasattaur/bin/qml";
            "dart.flutterSdkPath" = "/mnt/DATA/Programming/SDK/Flutter/flutter";
            "terminal.integrated.profiles.linux" = {
              bash = {
                path = "bash";
                icon = "terminal-bash";
              };
              zsh = {
                path = "zsh";
              };
              fish = {
                path = "/etc/profiles/per-user/zackariyyasattaur/bin/fish";
              };
              tmux = {
                path = "tmux";
                icon = "terminal-tmux";
              };
              pwsh = {
                path = "pwsh";
                icon = "terminal-powershell";
              };
            };
            "terminal.integrated.defaultProfile.linux" = "fish";
          };
        };

        # Manually put it in the file because it would complain
        # argvSettings = {
        #   "enable-crash-reporter" = false;
        #   "password-store" = "kwallet6";
        # };

      };
    };
}
