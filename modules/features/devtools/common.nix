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
    let
      mkproj = pkgs.writeShellApplication {
        name = "mkproj";
        runtimeInputs = [
          pkgs.jq
          pkgs.gum
        ];
        text = ''
          #!/usr/bin/env bash

          set -e

          DEFAULT_SOURCE="github:rzi3d"

          # --- Mode 1: Fast Track (Arguments Provided) ---
          if [ "$#" -gt 0 ]; then
              NAME=$1
              if [ "$2" = "-t" ] && [ -n "$3" ]; then
                  TEMPLATE=$3
                  echo "Creating project '$NAME' using template '$TEMPLATE'..."
                  # Format the default source cleanly to avoid path-parsing bugs
                  nix flake new "$NAME" -t "github:rzi3d/templates#''${TEMPLATE}"
                  exit 0
              else
                  echo "ERROR: Invalid arguments."
                  echo "Usage: $0 <name> -t <template>"
                  echo "$0 (interactive)"
                  exit 1
              fi
          fi

          # --- Mode 2: Interactive Wizard (No Arguments) ---

          if ! command -v gum &> /dev/null; then
              echo "ERROR: 'gum' is required for the interactive wizard. Please install it first."
              exit 1
          fi

          if ! command -v jq &> /dev/null; then
              echo "ERROR: 'jq' is required for the interactive wizard. Please install it first."
              exit 1
          fi

          echo "RZI Quick Project Creator"

          # 1. Ask for template source
          SOURCE=$(gum input --value="$DEFAULT_SOURCE" --placeholder "Template source (e.g., github:owner/repo)")

          # 2. Extract owner/repo to ensure it's explicitly structured
          if [[ "$SOURCE" =~ ^github:([^/]+)(/([^/]+))?$ ]]; then
              OWNER="''${BASH_REMATCH[1]}"
              REPO="''${BASH_REMATCH[3]}"
              if [ -z "$REPO" ]; then
                  REPO="templates"
              fi
              TARGET_FLAKE="github:''${OWNER}/''${REPO}"
          else
              TARGET_FLAKE="$SOURCE"
          fi

          TEMPLATES=""
          echo "Evaluating available templates from $TARGET_FLAKE..."

          # Use nix eval + jq for rock-solid parsing
          TEMPLATES=$(nix eval --json "''${TARGET_FLAKE}#templates" --refresh --apply "builtins.attrNames" 2>/dev/null | jq -r '.[]' || true)

          # 3. Choose template via interactive list or manual entry fallback
          if [ -z "$TEMPLATES" ]; then
              echo "Could not automatically parse templates from source. Falling back to manual entry."
              TEMPLATE=$(gum input --placeholder "Enter template name manually")
          else
              TEMPLATE=$(echo "$TEMPLATES" | gum choose --header "Select a template:")
          fi

          # 4. Ask for project name
          NAME=$(gum input --placeholder "Enter your project name")

          if [ -z "$NAME" ]; then
              echo "ERROR: Project name cannot be empty."
              exit 1
          fi

          # 5. Run the nix command
          # Using explicit `-t` option passing order resolves the ambiguous path parsing bug.
          echo "Creating project ''${NAME} using template ''${TARGET_FLAKE}#''${TEMPLATE}..."
          nix flake new "$NAME" -t "''${TARGET_FLAKE}#''${TEMPLATE}" --refresh
          cd "$NAME"
        '';
      };
    in
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
        pi-coding-agent
        nodejs # Most MCP servers require nodejs
        devenv
        mkproj
        tio # tty device access
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

            # QT
            #"TheQtCompany.qt-core" # required base for all others
            #"TheQtCompany.qt-qml" # QML language support, Quickshell issues
            #"TheQtCompany.qt-cpp" # Qt C++ support
            #"TheQtCompany.qt-ui" # .ui file designer

            "jnoortheen.nix-ide" # Nix Syntax Highlighting

            "esbenp.prettier-vscode" # Formatting
            "alefragnani.Bookmarks"

            "dtoplak.vscode-glsllint"
            "slevesque.shader"

            "thijsdaniels.vscode-openscad-preview"
            "Leathong.openscad-language-support"
          ];
          userSettings = {
            "catppuccin.accentColor" = "sapphire";
            "editor.formatOnSave" = true;
            "editor.semanticHighlighting.enabled" = true;
            "workbench.tree.renderIndentGuides" = "always";
            "workbench.tree.indent" = 12;
            "todo-tree.ripgrep" = "/run/current-system/sw/bin/rg";
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
            # "dart.flutterSdkPath" = "/mnt/DATA/Programming/SDK/Flutter/flutter";
            "dart.flutterCreatePlatforms" = [
              "android"
              "ios"
              "linux"
              "macos"
              "windows"
            ];

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
            "C_Cpp.intelliSenseEngine" = "disabled";
            "files.insertFinalNewline" = true;
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
