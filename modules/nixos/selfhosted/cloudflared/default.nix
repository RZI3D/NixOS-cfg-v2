{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.cloudflared;
in
{
  options.rzi.selfhosted.cloudflared.enable = lib.mkEnableOption "Cloudflare Tunnel (selfhosted)";

  config = lib.mkIf cfg.enable {
    sops.secrets."cloudflared-credentials" = { };

    services.cloudflared = {
      enable = true;
      tunnels."360a9b1d-96cf-499d-a59a-793b287d0dce" = {
        credentialsFile = config.sops.secrets."cloudflared-credentials".path;
        default = "http_status:404";
        ingress = {
          # I should probably order the ports or something...
          "auth.rzi.dpdns.org" = "http://localhost:9000";
          "books.rzi.dpdns.org" = "http://localhost:6060";
          "romm.rzi.dpdns.org" = "http://localhost:8080";
          "audiobooks.rzi.dpdns.org" = "http://localhost:7070";
          "jellyfin.rzi.dpdns.org" = "http://localhost:8096";
          "photos.rzi.dpdns.org" = "http://localhost:2283";
          "mcmap.rzi.dpdns.org" = "http://localhost:8100";
          "assets.rzi.dpdns.org" = "http://localhost:8091";
          "git.rzi.dpdns.org" = "http://localhost:4500";
          "notes.rzi.dpdns.org" = "http://localhost:3005";
          "cloud.rzi.dpdns.org" = "http://localhost:9200";
          "collabora.rzi.dpdns.org" = "http://localhost:9980";
        };
      };
    };
  };
}
