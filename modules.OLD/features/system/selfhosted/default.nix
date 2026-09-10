{
  self,
  ...
}:
{
  flake.nixosModules.selfhosted =
    { ... }:
    {
      imports = [
        self.nixosModules."selfhosted-podman"
        self.nixosModules."selfhosted-forgejo-server"
        self.nixosModules."selfhosted-forgejo-runner"
        self.nixosModules."selfhosted-authentik"
        self.nixosModules."selfhosted-romm"
        self.nixosModules."selfhosted-grimmory"
        self.nixosModules."selfhosted-jellyfin"
        self.nixosModules."selfhosted-immich"
        self.nixosModules."selfhosted-audiobookshelf"
        self.nixosModules."selfhosted-filebrowser"
        self.nixosModules."selfhosted-cloudflared"
        self.nixosModules."selfhosted-asset-server"

        # Disabled by default — uncomment to enable
        # self.nixosModules."selfhosted-multiuser-server"
      ];
    };
}