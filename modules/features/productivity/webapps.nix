{ self, inputs, ... }:
{
  flake.nixosModules.ffWebApps =
    { ... }:
    {
      imports = [ self.homeModules.firefoxWebapps ];
      programs.firefox.webapps = {
        claude = {
          name = "Claude Web";
          url = "https://claude.ai";
          id = 10;
          theme = "dark";
          icon = builtins.fetchurl {
            url = "https://upload.wikimedia.org/wikipedia/commons/b/b0/Claude_AI_symbol.svg";
            sha256 = "1q6vlkqad07m7pk668q9jcdnx3pcigij87zp1hgwaqilq3lj6rly";
          };
        };

        notebooklm = {
          name = "NotebookLM";
          url = "https://notebooklm.google.com/";
          id = 11;
          theme = "dark";
          icon = builtins.fetchurl {
            url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/notebook-lm-dark.svg";
            sha256 = "1aap0i17scfxl2ycfybc6x6fa7glilw4k522nya8vzqza4fa4ll0";
          };
        };

        gemini = {
          name = "Google Gemini";
          url = "https://gemini.google.com/";
          id = 12;
          theme = "dark";
          icon = builtins.fetchurl {
            name = "gemini.png";
            url = "https://uxwing.com/wp-admin/admin-ajax.php?action=resize_image&size=32x32&file=google-gemini-icon.png&category_slug=brands-and-social-media";
            sha256 = "1ky8s6rn28f56132c3nr9x4vh1x4kmhwscch8m0ykrlhwvavg2ks";
          };
        };

        figma = {
          name = "Figma";
          url = "https://www.figma.com";
          id = 13;
          theme = "dark";
          icon = builtins.fetchurl {
            url = "https://upload.wikimedia.org/wikipedia/commons/3/33/Figma-logo.svg";
            sha256 = "11x72ik5mndqmnnmw8jph9bnalkr9z634ggnk82s2f72w8gb24wm";
          };
        };

        opencut = {
          name = "OpenCut";
          url = "https://opencut.app/projects";
          id = 14;
          theme = "dark";
          icon = builtins.fetchurl {
            name = "opencut.svg";
            url = "https://opencut.app/logos/opencut/svg/logo.svg";
            sha256 = "9f3f94ff1cc9fabb21f80ce478b292d9e479a53560f6a3f9b2daead48b053d3f";
          };
        };

        flashfx = {
          name = "FlashFX";
          url = "https://editor.flashfx.app/";
          id = 15;
          theme = "dark";
          icon = builtins.fetchurl {
            name = "flashfx.png";
            url = "https://flashfx.app/android-chrome-192x192.png";
            sha256 = "48e774a48de3270af1d69bb0858447ae9263983ba3a26391ba8fddfeebcc3803";
          };
        };
      };
    };
}
