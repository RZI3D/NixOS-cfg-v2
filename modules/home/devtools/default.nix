{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.devtools;

  mkproj = pkgs.writeShellApplication {
    name = "mkproj";
    runtimeInputs = [
      pkgs.jq
      pkgs.gum
    ];
    text = ''
      set -e
      DEFAULT_SOURCE="github:rzi3d"

      if [ "$#" -gt 0 ]; then
          NAME=$1
          if [ "$2" = "-t" ] && [ -n "$3" ]; then
              TEMPLATE=$3
              nix flake new "$NAME" -t "github:rzi3d/templates#''${TEMPLATE}"
              exit 0
          else
              echo "ERROR: Invalid arguments."
              echo "Usage: $0 <name> -t <template>"
              echo "$0 (interactive)"
              exit 1
          fi
      fi

      echo "RZI Quick Project Creator"
      SOURCE=$(gum input --value="$DEFAULT_SOURCE" --placeholder "Template source (e.g., github:owner/repo)")

      if [[ "$SOURCE" =~ ^github:([^/]+)(/([^/]+))?$ ]]; then
          OWNER="''${BASH_REMATCH[1]}"
          REPO="''${BASH_REMATCH[3]}"
          if [ -z "$REPO" ]; then REPO="templates"; fi
          TARGET_FLAKE="github:''${OWNER}/''${REPO}"
      else
          TARGET_FLAKE="$SOURCE"
      fi

      TEMPLATES=$(nix eval --json "''${TARGET_FLAKE}#templates" --refresh --apply "builtins.attrNames" 2>/dev/null | jq -r '.[]' || true)

      if [ -z "$TEMPLATES" ]; then
          TEMPLATE=$(gum input --placeholder "Enter template name manually")
      else
          TEMPLATE=$(echo "$TEMPLATES" | gum choose --header "Select a template:")
      fi

      NAME=$(gum input --placeholder "Enter your project name")

      if [ -z "$NAME" ]; then
          echo "ERROR: Project name cannot be empty."
          exit 1
      fi

      nix flake new "$NAME" -t "''${TARGET_FLAKE}#''${TEMPLATE}" --refresh
      cd "$NAME"
    '';
  };
in
{
  options.rzi.devtools.enable = lib.mkEnableOption "Development tools (hmModule)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gh
      helix
      htop
      nil
      nixfmt
      nixd
      qt6.qtdeclarative
      kdePackages.qttools
      opencode
      pi-coding-agent
      zed-editor # until zed has a program.options
      nodejs
      devenv
      mkproj
      tio
      jujutsu
      jjui
    ];

    programs.git = {
      enable = true;

      package =
        (pkgs.git.override {
          withLibsecret = true;
        }).overrideAttrs
          (old: {
            doCheck = false;
            doInstallCheck = false;
          });

      signing.format = null;
      settings = {
        credential.helper = "libsecret";
        user = {
          name = "rzi3d";
          email = "zackiesattaur@gmail.com";
        };
        init.defaultBranch = "main";
      };
    };

    programs.helix = {
      enable = true;
      settings.editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
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
      nix-direnv.enable = true;
      config.global.log_filter = "^loading";
    };

    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = pkgs.nix4vscode.forVscode [
          "bierner.color-info"
          "bierner.markdown-checkbox"
          "bierner.markdown-emoji"
          "bierner.markdown-footnotes"
          "bierner.markdown-mermaid"
          "catppuccin.catppuccin-vsc"
          "illixion.vscode-vibrancy-continued"
          "oderwat.indent-rainbow"
          "roonie007.hide-files"
          "Gruntfuggly.todo-tree"
          "charliermarsh.ruff"
          "codezombiech.gitignore"
          "dart-code.dart-code"
          "dart-code.flutter"
          "geequlim.godot-tools"
          "golang.go"
          "mkhl.direnv"
          "platformio.platformio-ide"
          "redhat.vscode-yaml"
          "tamasfe.even-better-toml"
          "swiftlang.swift-vscode"
          "llvm-vs-code-extensions.vscode-clangd"
          "llvm-vs-code-extensions.lldb-dap"
          "vadimcn.vscode-lldb"
          "ms-vscode.cmake-tools"
          "ms-vscode.cpp-devtools"
          "ms-vscode.cpptools"
          "ms-vscode.cpptools-extension-pack"
          "ms-vscode.cpptools-themes"
          "ms-vscode.makefile-tools"
          "ms-python.python"
          "ms-python.debugpy"
          "ms-python.vscode-pylance"
          "ms-python.vscode-python-envs"
          "donjayamanne.githistory"
          "mhutchie.git-graph"
          "github.codespaces"
          "github.remotehub"
          "github.vscode-github-actions"
          "github.vscode-pull-request-github"
          "google.gemini-cli-vscode-ide-companion"
          "pi0.pi-vscode"
          "ms-azuretools.vscode-containers"
          "ms-vscode-remote.remote-containers"
          "ms-vscode.remote-explorer"
          "ms-vscode.remote-repositories"
          "ms-vscode.remote-server"
          "ms-vscode.vscode-github-issue-notebooks"
          "ms-vsliveshare.vsliveshare"
          "jnoortheen.nix-ide"
          "esbenp.prettier-vscode"
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
          "todo-tree.ripgrep.ripgrep" = "${lib.getExe pkgs.ripgrep}";
          "vscode_vibrancy.theme" = "Catppuccin Mocha";
          "terminal.integrated.gpuAcceleration" = "off";
          "vscode_vibrancy.opacity" = 0.9;
          "terminal.integrated.minimumContrastRatio" = 1;
          "window.titleBarStyle" = "custom";
          "workbench.colorTheme" = "Catppuccin Mocha";
          "workbench.iconTheme" = "catppuccin-mocha";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
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
            fish = {
              path = "/etc/profiles/per-user/zackariyyasattaur/bin/fish";
            };
            nu = {
              path = "/etc/profiles/per-user/zackariyyasattaur/bin/nu";
            };
          };
          "terminal.integrated.defaultProfile.linux" = "nu";
          "terminal.integrated.env.linux" = {
            "SKIP_MICROFETCH" = "1";
          };
          "C_Cpp.intelliSenseEngine" = "disabled";
          "files.insertFinalNewline" = true;
          "yaml.disableSchemaDetection" = [
            "**/.github/workflows/*.yml"
            "**/.github/workflows/*.yaml"
            "**/.gitea/workflows/*.yml"
            "**/.gitea/workflows/*.yaml"
            "**/.forgejo/workflows/*.yml"
            "**/.forgejo/workflows/*.yaml"
          ];
        };
      };
    };
  };
}
