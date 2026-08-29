{
  config,
  pkgs,
  inputs,
  ...
}:
{
  flake.nixosModules.selfHostedServices =
    { pkgs, config, ... }:
    let
      devenvCiImage = pkgs.dockerTools.buildLayeredImage {
        name = "devenv-ci";
        tag = "latest";

        fromImage = pkgs.dockerTools.pullImage {
          imageName = "ghcr.io/cachix/devenv/devenv";
          imageDigest = "sha256:770d57ba236961e23cd7d82314573084afcc473eb97b512fd244d214864f9233";
          hash = "sha256-5ssn8JigkkDBlhB1irqhx404x8KUSvvVU3Fur0u/YNo=";
          finalImageName = "ghcr.io/cachix/devenv/devenv";
          finalImageTag = "latest";
        };

        contents = with pkgs; [
          nodejs_22
          curl
          gnutar
          gzip
          zstd
          rsync
          jq
        ];

        config = {
          User = "root";
          Env = [
            "PATH=/bin:/home/devenv/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin"
            "HOME=/root"
          ];
        };
      };

    in
    {

      sops.templates."romm-db.env".content = ''
        MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm/MARIADB_ROOT_PASSWORD"}
        MARIADB_PASSWORD=${config.sops.placeholder."romm/MARIADB_PASSWORD"}
      '';

      sops.templates."romm.env".content = ''
        DB_PASSWD=${config.sops.placeholder."romm/DB_PASSWD"}
        ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/ROMM_AUTH_SECRET_KEY"}
        IGDB_CLIENT_ID=${config.sops.placeholder."romm/IGDB_CLIENT_ID"}
        IGDB_CLIENT_SECRET=${config.sops.placeholder."romm/IGDB_CLIENT_SECRET"}
        SCREENSCRAPER_USER=${config.sops.placeholder."romm/SCREENSCRAPER_USER"}
        SCREENSCRAPER_PASSWORD=${config.sops.placeholder."romm/SCREENSCRAPER_PASSWORD"}
        STEAMGRIDDB_API_KEY=${config.sops.placeholder."romm/STEAMGRIDDB_API_KEY"}
        OIDC_CLIENT_ID=${config.sops.placeholder."romm/OIDC_CLIENT_ID"}
        OIDC_CLIENT_SECRET=${config.sops.placeholder."romm/OIDC_CLIENT_SECRET"}
      '';

      sops.templates."grimmory-db.env".content = ''
        MARIADB_ROOT_PASSWORD=${config.sops.placeholder."grimmory/db_root_password"}
        MARIADB_PASSWORD=${config.sops.placeholder."grimmory/db_user_password"}
      '';

      sops.templates."grimmory.env".content = ''
        DATABASE_PASSWORD=${config.sops.placeholder."grimmory/db_user_password"}
      '';

      sops.templates."multiuser.env".content = ''
        password=${config.sops.placeholder."multiuser-password"}
        admin_password=${config.sops.placeholder."multiuser-admin-password"}
      '';

      sops.templates."authentik.env".content = ''
        PG_USER=authentik
        PG_DB=authentik
        PG_PASS=${config.sops.placeholder."authentik/pg_pass"}
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}

        POSTGRES_PASSWORD=${config.sops.placeholder."authentik/pg_pass"}
        POSTGRES_USER=authentik
        POSTGRES_DB=authentik
      '';

      sops.templates."forgejo-runner-token".content = ''
        TOKEN=${config.sops.placeholder."forgejo-runner-token"}
      '';

      systemd.services.build-devenv-ci-image = {
        description = "Build and load devenv-ci image into Podman";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        requires = [ "podman.socket" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.podman}/bin/podman load -i ${devenvCiImage}";
        };
      };

      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      virtualisation.oci-containers.containers = {

        asset-server = {
          image = "docker.io/library/caddy:latest";
          ports = [ "127.0.0.1:8091:80" ]; # bind local, tunnel handles public exposure
          volumes = [
            "/srv/assets:/srv/assets:ro"
          ];
          cmd = [
            "caddy"
            "file-server"
            "--root"
            "/srv/assets"
            "--browse=false"
          ];
        };

        # ______ START ROMM STACK ______

        romm-db = {
          image = "mariadb:latest";
          environmentFiles = [ config.sops.templates."romm-db.env".path ];
          environment = {
            MARIADB_DATABASE = "romm";
            MARIADB_USER = "romm-user";
          };
          volumes = [
            "/var/lib/romm/mysql:/var/lib/mysql"
          ];
        };

        romm = {
          image = "rommapp/romm:5.0.0-beta.2";
          dependsOn = [ "romm-db" ];
          ports = [ "8080:8080" ];
          environmentFiles = [ config.sops.templates."romm.env".path ];
          environment = {
            DB_HOST = "romm-db";
            DB_NAME = "romm";
            DB_USER = "romm-user";

            PLAYMATCH_API_ENABLED = "true";
            LAUNCHBOX_API_ENABLED = "true";
            HASHEOUS_API_ENABLED = "true";

            OIDC_ENABLED = "true";
            OIDC_PROVIDER = "authentik";
            OIDC_REDIRECT_URI = "https://romm.rzi.dpdns.org/api/oauth/openid";
            OIDC_SERVER_APPLICATION_URL = "https://auth.rzi.dpdns.org/application/o/romm/";
            OIDC_AUTOLOGIN = "true";

            OIDC_CLAIM_ROLES = "romm-groups";
            OIDC_ROLE_ADMIN = "admin";
            OIDC_ROLE_EDITOR = "editor";
            OIDC_ROLE_VIEWER = "viewer";

          };
          volumes = [
            "/mnt/DATA/SrvData/romM/library:/romm/library"
            "/mnt/DATA/SrvData/romM/resources:/romm/resources"
            "/mnt/DATA/SrvData/romM/assets:/romm/assets"
            "/mnt/DATA/SrvData/romM/redis:/redis-data"
            "/mnt/DATA/SrvData/romM/config:/romm/config"
          ];
        };

        # ______ END ROMM STACK ______

        # ______ START GRIMMORY STACK ______

        grimmory-db = {
          image = "mariadb:11";
          environmentFiles = [ config.sops.templates."grimmory-db.env".path ];
          environment = {
            MARIADB_DATABASE = "grimmory";
            MARIADB_USER = "grimmory";
          };

          volumes = [
            "/var/lib/grimmory/mysql:/var/lib/mysql"
          ];
        };

        grimmory = {
          image = "ghcr.io/grimmory-tools/grimmory:v3.2.2";
          dependsOn = [ "grimmory-db" ];
          ports = [ "6060:6060" ];
          environmentFiles = [ config.sops.templates."grimmory.env".path ];
          environment = {
            DATABASE_URL = "jdbc:mariadb://grimmory-db:3306/grimmory";
            DATABASE_USERNAME = "grimmory";
          };

          volumes = [
            "/mnt/DATA/SrvData/grimmory/books:/books"
            "/mnt/DATA/SrvData/grimmory/bookdrop:/bookdrop"
            "/mnt/DATA/SrvData/grimmory/data:/app/data"
          ];
        };

        # ______ END GRIMMORY STACK ______

        # ______ START AUTHENTIK STACK ______
        authentik-postgresql = {
          image = "docker.io/library/postgres:16-alpine";
          environmentFiles = [ config.sops.templates."authentik.env".path ];
          environment = {
            POSTGRES_DB = "authentik";
            POSTGRES_USER = "authentik";
          };
          volumes = [
            "/var/lib/authentik/postgres:/var/lib/postgresql/data"
          ];
          extraOptions = [ "--health-cmd=pg_isready -d authentik -U authentik" ];
          autoStart = true;
        };

        authentik-server = {
          image = "ghcr.io/goauthentik/server:2026.5.3";
          dependsOn = [ "authentik-postgresql" ];
          environmentFiles = [ config.sops.templates."authentik.env".path ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
          };
          cmd = [ "server" ];
          ports = [
            "9000:9000"
            "9443:9443"
          ];
          volumes = [
            "/var/lib/authentik/data:/data"
            "/var/lib/authentik/custom-templates:/templates"
            "/var/lib/authentik/media:/media"
          ];
          extraOptions = [ "--shm-size=512m" ];
          autoStart = true;
        };

        authentik-worker = {
          image = "ghcr.io/goauthentik/server:2026.5.3";
          dependsOn = [ "authentik-postgresql" ];
          environmentFiles = [ config.sops.templates."authentik.env".path ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
          };
          cmd = [ "worker" ];
          volumes = [
            "/var/lib/authentik/data:/data"
            "/var/lib/authentik/custom-templates:/templates"
            "/var/lib/authentik/media:/media"
          ];
          extraOptions = [ "--shm-size=512m" ];
          autoStart = true;
        };
        # ______ END AUTHENTIK STACK ______

      };

      services.forgejo = {
        enable = true;
        database.type = "postgres";
        stateDir = "/mnt/DATA/SrvData/forgejo";
        settings = {
          server = {
            DOMAIN = "git.rzi.dpdns.org";
            ROOT_URL = "https://git.rzi.dpdns.org/";
            #LOCAL_ROOT_URL = "http://host.containers.internal:3000/";
            HTTP_PORT = 3000;
            LANDING_PAGE = "home";
          };
          ui = {
            THEMES = "catppuccin-latte-rosewater,catppuccin-latte-flamingo,catppuccin-latte-pink,catppuccin-latte-mauve,catppuccin-latte-red,catppuccin-latte-maroon,catppuccin-latte-peach,catppuccin-latte-yellow,catppuccin-latte-green,catppuccin-latte-teal,catppuccin-latte-sky,catppuccin-latte-sapphire,catppuccin-latte-blue,catppuccin-latte-lavender,catppuccin-frappe-rosewater,catppuccin-frappe-flamingo,catppuccin-frappe-pink,catppuccin-frappe-mauve,catppuccin-frappe-red,catppuccin-frappe-maroon,catppuccin-frappe-peach,catppuccin-frappe-yellow,catppuccin-frappe-green,catppuccin-frappe-teal,catppuccin-frappe-sky,catppuccin-frappe-sapphire,catppuccin-frappe-blue,catppuccin-frappe-lavender,catppuccin-macchiato-rosewater,catppuccin-macchiato-flamingo,catppuccin-macchiato-pink,catppuccin-macchiato-mauve,catppuccin-macchiato-red,catppuccin-macchiato-maroon,catppuccin-macchiato-peach,catppuccin-macchiato-yellow,catppuccin-macchiato-green,catppuccin-macchiato-teal,catppuccin-macchiato-sky,catppuccin-macchiato-sapphire,catppuccin-macchiato-blue,catppuccin-macchiato-lavender,catppuccin-mocha-rosewater,catppuccin-mocha-flamingo,catppuccin-mocha-pink,catppuccin-mocha-mauve,catppuccin-mocha-red,catppuccin-mocha-maroon,catppuccin-mocha-peach,catppuccin-mocha-yellow,catppuccin-mocha-green,catppuccin-mocha-teal,catppuccin-mocha-sky,catppuccin-mocha-sapphire,catppuccin-mocha-blue,catppuccin-mocha-lavender";
          };
          service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true; # login via Authentik

          openid = {
            ENABLE_OPENID_SIGNIN = false;
            ENABLE_OPENID_SIGNUP = false;
          };

        };
      };

      systemd.services."gitea-runner-rzi\\x2dmac\\x2dpro" = {
        unitConfig = {
          # Ensure systemd waits for and builds the mount dependency for /mnt/DATA
          RequiresMountsFor = [ "/mnt/DATA/SrvData/forgejo-runner/cache" ];
        };
        serviceConfig = {
          # Expose the external cache path as writable inside the sandbox
          ReadWritePaths = [ "/mnt/DATA/SrvData/forgejo-runner/cache" ];
        };
      };

      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances.rzi-mac-pro = {
          enable = true;
          name = "rzi-mac-pro";
          url = "http://localhost:3000/";
          tokenFile = config.sops.templates."forgejo-runner-token".path;
          settings = {
            container.network = "host";
            cache = {
              dir = "/mnt/DATA/SrvData/forgejo-runner/cache";
              offline_mode = true;
              enabled = true;
            };
          };
          labels = [
            "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
            "devenv:docker://localhost/devenv-ci:latest"
            "nix:docker://nixos/nix"
          ];
        };
      };

      services.jellyfin = {
        enable = true;
        openFirewall = true;
        dataDir = "/mnt/DATA/SrvData/jellyfin";
      };

      services.immich = {
        enable = true;
        mediaLocation = "/mnt/DATA/SrvData/immich";
        host = "0.0.0.0";
        port = 2283;
        openFirewall = true;
        environment.IMMICH_LOG_LEVEL = "warn";
      };

      services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = 7070;
        openFirewall = true;
      };

      services.filebrowser = {
        enable = true;
        settings.root = "/mnt/DATA/SrvData/filebrowser";
        settings.address = "0.0.0.0";
        settings.port = 8069;
        openFirewall = true;
      };

      services.cloudflared = {
        enable = true;
        tunnels."360a9b1d-96cf-499d-a59a-793b287d0dce" = {
          credentialsFile = config.sops.secrets."cloudflared-credentials".path;
          default = "http_status:404";
          ingress = {
            "auth.rzi.dpdns.org" = "http://localhost:9000";
            "books.rzi.dpdns.org" = "http://localhost:6060";
            "romm.rzi.dpdns.org" = "http://localhost:8080";
            "audiobooks.rzi.dpdns.org" = "http://localhost:7070";
            "jellyfin.rzi.dpdns.org" = "http://localhost:8096";
            "photos.rzi.dpdns.org" = "http://localhost:2283";
            "mcmap.rzi.dpdns.org" = "http://localhost:8100";
            "assets.rzi.dpdns.org" = "http://localhost:8091";
            "git.rzi.dpdns.org" = "http://localhost:3000";
          };
        };
      };

    };
}
