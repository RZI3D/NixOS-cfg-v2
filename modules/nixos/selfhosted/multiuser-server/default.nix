{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.selfhosted.multiuser-server;
in
{
  options.rzi.selfhosted.multiuser-server.enable = lib.mkEnableOption "Multi-user server secrets (selfhosted)";

  config = lib.mkIf cfg.enable {
    sops.templates."multiuser.env".content = ''
      password=${config.sops.placeholder."multiuser-password"}
      admin_password=${config.sops.placeholder."multiuser-admin-password"}
    '';

    sops.secrets = {
      "multiuser-password" = { };
      "multiuser-admin-password" = { };
    };
  };
}
