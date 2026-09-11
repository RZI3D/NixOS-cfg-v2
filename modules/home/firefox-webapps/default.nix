{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (builtins) getAttr stringLength substring;
  inherit (lib) mkOption;
  inherit (lib.attrsets) mapAttrs mapAttrs' nameValuePair;
  inherit (lib.strings) concatStringsSep toUpper;

  cfg = config.rzi.firefox-webapps;

  make-app-profiles =
    cfgs:
    mapAttrs' (
      name: c:
      nameValuePair "home-manager-webapp-${name}" {
        id = c.id;
        extensions.force = true;
        userChrome = ''
          @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
          @namespace html url("http://www.w3.org/1999/xhtml");
          browser { margin-right: 0px; margin-bottom: 0px; }
          #TabsToolbar { visibility: collapse !important; }
          #nav-bar { margin-top: 0; margin-bottom: -42px; z-index: -100; }
          html|moz-urlbar { opacity: 0 !important; pointer-events: none !important; transition: opacity 0.15s ease !important; }
          html|moz-urlbar:focus-within { opacity: 1 !important; pointer-events: auto !important; }
          #main-window[windowtype="navigator:browser"] { background-color: transparent !important; }
          .tab-background[selected="true"] { background: ${c.backgroundColor} !important; }
        '';
        settings = c.extraSettings // {
          "browser.sessionstore.resume_session_once" = false;
          "browser.sessionstore.resume_from_crash" = false;
          "browser.cache.disk.enable" = false;
          "browser.cache.disk.capacity" = 0;
          "browser.cache.disk.filesystem_reported" = 1;
          "browser.cache.disk.smart_size.enabled" = false;
          "browser.cache.disk.smart_size.first_run" = false;
          "browser.cache.disk.smart_size.use_old_max" = false;
          "browser.ctrlTab.previews" = true;
          "browser.tabs.warnOnClose" = false;
          "plugin.state.flash" = 2;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.drawInTitlebar" = false;
          "browser.tabs.inTitlebar" = 0;
          "browser.contentblocking.category" = "strict";
          "network.cookie.lifetimePolicy" = 0;
          "layout.css.prefers-color-scheme.content-override" = getAttr c.theme { dark = 0; light = 1; system = 2; };
        };
      }
    ) cfgs;
in
{
  options.rzi.firefox-webapps.enable = lib.mkEnableOption "Firefox PWA webapps (hmModule)";
  options.programs.firefox.webapps = mkOption {
    default = { };
    type = with lib.types; attrsOf (submodule {
      options = {
        url = mkOption { type = str; description = "The URL of the webapp to launch."; };
        id = mkOption { type = int; description = "The Firefox profile ID to set."; };
        extraArgs = mkOption { type = listOf str; default = [ ]; description = "Extra args to launch Firefox with."; };
        extraSettings = mkOption { type = attrsOf (either bool (either int str)); default = { }; description = "Additional Firefox profile settings."; };
        backgroundColor = mkOption { type = str; default = "rgba(0, 0, 0, 0)"; description = "The background color to use for loading pages."; };
        theme = mkOption { type = enum [ "dark" "light" "system" ]; default = "system"; description = "The application CSS theme to use."; };
        name = mkOption { type = nullOr str; default = null; description = "Specific name of the application."; };
        mimeType = mkOption { type = nullOr (listOf str); default = [ "text/html" "text/xml" "application/xhtml_xml" ]; description = "The MIME type(s) supported."; };
        genericName = mkOption { type = nullOr str; default = null; description = "Generic name of the application."; };
        comment = mkOption { type = nullOr str; default = null; description = "Tooltip for the entry."; };
        categories = mkOption { type = nullOr (listOf str); default = null; description = "Categories for the menu."; };
        icon = mkOption { type = nullOr (either str path); default = null; description = "Icon for file manager, menus, etc."; };
        prefersNonDefaultGPU = mkOption { type = nullOr bool; default = null; description = "Whether the app prefers a discrete GPU."; };
      };
    });
    description = "Websites to create special site-specific Firefox instances for.";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.profiles = make-app-profiles config.programs.firefox.webapps;

    xdg.desktopEntries = mapAttrs (name: wc: {
      inherit (wc) genericName comment categories icon mimeType prefersNonDefaultGPU;
      name = if wc.name == null then (toUpper (substring 0 1 name)) + (substring 1 (stringLength name) name) else wc.name;
      startupNotify = true;
      terminal = false;
      type = "Application";
      exec = concatStringsSep " " (
        [ "${config.programs.firefox.package}/bin/firefox" "--class" "WebApp-${name}" "--profile"
          "${config.home.homeDirectory}/.mozilla/firefox/${config.programs.firefox.profiles."home-manager-webapp-${name}".path}"
          "--no-remote" ]
        ++ wc.extraArgs ++ [ wc.url ]
      );
      settings = {
        X-MultipleArgs = "false";
        StartupWMClass = "WebApp-${name}";
      };
    }) config.programs.firefox.webapps;
  };
}