{ self, inputs, pkgs, ... }:
{
  flake.homeModules.browsers =
    { pkgs, ... }:
    {
      # Probally not the most modular way (TODO: Look at later)

      home.packages = with pkgs; [
        helium
      ];

      programs.thunderbird = {
        enable = true;

        profiles."Zackariyya Sattaur" = {
          isDefault = true;
        };

      };

      programs.firefox = {
        enable = true;

        # This applies settings to ALL profiles
        policies = {
          ExtensionSettings =
            with builtins;
            let
              extension = shortId: uuid: {
                name = uuid;
                value = {
                  install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                  installation_mode = "normal_installed";
                };
              };
            in
            listToAttrs [
              (extension "ublock-origin" "uBlock0@raymondhill.net")
              (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
              (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
              (extension "youtube-addon" "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}")
              (extension "auth-helper" "authenticator@mymindstorm")
              (extension "auto-tab-discard" "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}")
              (extension "darkreader" "addon@darkreader.org")
              (extension "firefox-color" "FirefoxColor@mozilla.com")
              (extension "live-editor-for-css-less-sass" "{a42eb16c-2fab-4c06-b1f3-5f15adebb0e3}")
              (extension "mynt" "{c30c387e-cd01-42b4-b5c7-6af2d820535b}")
              (extension "plasma-integration" "plasma-browser-integration@kde.org")
              (extension "react-devtools" "@react-devtools")
              (extension "refined-github-" "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}")
              (extension "user-agent-string-switcher" "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}")
              (extension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}")
            ];
          # To add additional extensions, find it on addons.mozilla.org, find
          # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
          # Then, download the XPI by filling it in to the install_url template, unzip it,
          # run `jq .browser_specific_settings.gecko.id manifest.json` or
          # `jq .applications.gecko.id manifest.json` to get the UUID

          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          OfferToSaveLogins = false; # Bitwarden

        };

        profiles.zackariyya = {
          extensions.force = true;
          isDefault = true;
          settings = {
            "browser.startup.page" = 3; # 3 = restore previous session
            "ui.systemUsesDarkTheme" = 1;
            "browser.in-content.dark-mode" = true;
          };
        };
      };
    };
}
