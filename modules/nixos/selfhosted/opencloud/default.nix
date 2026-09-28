{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.selfhosted.opencloud;

  cspYaml = pkgs.writeText "opencloud-csp.yaml" ''
    directives:
      connect-src:
        - "'self'"
        - "blob:"
        - "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
        - "https://update.opencloud.eu/"
        - "https://auth.rzi.dpdns.org/"
        - "https://collabora.rzi.dpdns.org/"
      frame-src:
        - "'self'"
        - "blob:"
        - "https://auth.rzi.dpdns.org/"
        - "https://collabora.rzi.dpdns.org/"
        - "wss://collabora.rzi.dpdns.org/"
      script-src:
        - "'self'"
        - "'unsafe-inline'"
  '';

  proxyYaml = pkgs.writeText "proxy.yaml" ''
    role_assignment:
      driver: oidc
      oidc_role_mapper:
        role_claim: opencloud_group
        role_mapping:
          - role_name: admin
            claim_value: admin
          - role_name: spaceadmin
            claim_value: spaceadmin
          - role_name: user
            claim_value: user
          - role_name: user-light
            claim_value: user-light
  '';
in
{
  options.rzi.selfhosted.opencloud.enable = lib.mkEnableOption "OpenCloud (selfhosted)";
  config = lib.mkIf cfg.enable {
    sops.secrets."opencloud/admin-passwd" = { };
    sops.secrets."collabora/admin-passwd" = { };

    sops.templates."opencloud.env".content = ''
      IDM_ADMIN_PASSWORD=${config.sops.placeholder."opencloud/admin-passwd"}
    '';

    sops.templates."collabora.env".content = ''
      password=${config.sops.placeholder."collabora/admin-passwd"}
    '';

    virtualisation.oci-containers.containers = {
      opencloud = {
        image = "docker.io/opencloudeu/opencloud-rolling:8.0.1";
        entrypoint = "/bin/sh";
        cmd = [
          "-c"
          "opencloud init --insecure=true || true; opencloud server"
        ];
        ports = [ "127.0.0.1:9200:9200" ];
        volumes = [
          "/mnt/DATA/SrvData/opencloud/config:/etc/opencloud"
          "/mnt/DATA/SrvData/opencloud/data:/var/lib/opencloud"
          "${cspYaml}:/etc/opencloud/csp.yaml:ro"
          "${proxyYaml}:/etc/opencloud/proxy.yaml:ro"
        ];
        environmentFiles = [ config.sops.templates."opencloud.env".path ];
        environment = {
          OC_URL = "https://cloud.rzi.dpdns.org";
          PROXY_TLS = "false";
          OC_INSECURE = "true";

          # OIDC / Authentik
          OC_OIDC_ISSUER = "https://auth.rzi.dpdns.org/application/o/opencloud/";
          OC_EXCLUDE_RUN_SERVICES = "idp";
          PROXY_OIDC_REWRITE_WELLKNOWN = "true";
          PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
          PROXY_AUTOPROVISION_ACCOUNTS = "true";
          PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
          PROXY_USER_OIDC_CLAIM = "preferred_username";
          PROXY_USER_CS3_CLAIM = "username";

          PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
          PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "opencloud_group";
          GRAPH_ASSIGN_DEFAULT_USER_ROLE = "false";
          WEB_OIDC_SCOPE = "openid profile email opencloud_group";

          GRAPH_USERNAME_MATCH = "none";
          SETTINGS_SETUP_DEFAULT_ASSIGNMENTS = "false";
          OC_ADMIN_USER_ID = "";
          WEB_OIDC_CLIENT_ID = "web";

          # Enable collaboration service inside the main process
          OC_ADD_RUN_SERVICES = "collaboration";

          # Collabora / WOPI
          COLLABORA_DOMAIN = "collabora.rzi.dpdns.org";
          COLLABORATION_APP_NAME = "CollaboraOnline";
          COLLABORATION_APP_PRODUCT = "Collabora";
          COLLABORATION_APP_ADDR = "https://collabora.rzi.dpdns.org";
          COLLABORATION_APP_ICON = "https://collabora.rzi.dpdns.org/favicon.ico";
          COLLABORATION_APP_INSECURE = "true";
          COLLABORATION_WOPI_SRC = "https://cloud.rzi.dpdns.org";
          COLLABORATION_CS3API_DATAGATEWAY_INSECURE = "true";

          # CSP
          PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";
        };
      };
      collabora = {
        image = "docker.io/collabora/code:latest";
        ports = [ "127.0.0.1:9980:9980" ];
        volumes = [
          "/mnt/DATA/SrvData/collabora/proof_key:/etc/coolwsd/proof_key:ro"
        ];
        environmentFiles = [ config.sops.templates."collabora.env".path ];
        environment = {
          aliasgroup1 = "https://cloud.rzi.dpdns.org:443";
          extra_params = "--o:ssl.enable=false --o:ssl.termination=true --o:welcome.enable=false --o:net.frame_ancestors=cloud.rzi.dpdns.org";
          username = "admin";
          DONT_GEN_SSL_CERT = "true";
        };
        extraOptions = [ "--cap-add=MKNOD" ];
      };
    };
  };
}
