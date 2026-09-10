{
  self,
  ...
}:
{
  flake.nixosModules."selfhosted-forgejo-runner" =
    { config, pkgs, ... }:
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
      imports = [ self.nixosModules."selfhosted-podman" ];

      sops.templates."forgejo-runner-token".content = ''
        TOKEN=${config.sops.placeholder."forgejo-runner-token"}
      '';

      sops.secrets."forgejo-runner-token" = { };

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

      systemd.services."gitea-runner-rzi\\x2dmac\\x2dpro" = {
        unitConfig = {
          RequiresMountsFor = [ "/mnt/DATA/SrvData/forgejo-runner/cache" ];
        };
        serviceConfig = {
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
    };
}