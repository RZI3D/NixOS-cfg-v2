{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted;
in
{
  options.rzi.selfhosted.enable = lib.mkEnableOption "Selfhosted service stack (nixosModule)";

  # The individual services live in ./<name>/default.nix and are auto-imported
  # by Snowfall; this aggregate just flips them all on together.

  # Enables the same set the old `selfhosted` aggregate imported.
  # `multiuser-server` is intentionally left opt-in (as before).
  config = lib.mkIf cfg.enable {
    rzi.selfhosted = {
      podman.enable = true;
      asset-server.enable = true;
      audiobookshelf.enable = true;
      authentik.enable = true;
      cloudflared.enable = true;
      filebrowser.enable = true;
      forgejo-runner.enable = true;
      forgejo-server.enable = true;
      grimmory.enable = true;
      immich.enable = true;
      jellyfin.enable = true;
      romm.enable = true;
      silverbullet.enable = true;
    };
  };
}
