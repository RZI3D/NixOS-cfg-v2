{
  config,
  ...
}:
{
  flake.nixosModules."selfhosted-multiuser-server" =
    { config, ... }:
    {
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