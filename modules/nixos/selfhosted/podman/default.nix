{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.podman;
in
{
  options.rzi.selfhosted.podman.enable = lib.mkEnableOption "Podman container runtime (selfhosted)";

  config = lib.mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      oci-containers.backend = "podman";
    };
  };
}
