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
    rzi.selfhosted.podman.enable = true;
    rzi.selfhosted.asset-server.enable = true;
    rzi.selfhosted.audiobookshelf.enable = true;
    rzi.selfhosted.authentik.enable = true;
    rzi.selfhosted.cloudflared.enable = true;
    rzi.selfhosted.filebrowser.enable = true;
    rzi.selfhosted.forgejo-runner.enable = true;
    rzi.selfhosted.forgejo-server.enable = true;
    rzi.selfhosted.grimmory.enable = true;
    rzi.selfhosted.immich.enable = true;
    rzi.selfhosted.jellyfin.enable = true;
    rzi.selfhosted.romm.enable = true;
  };
}
