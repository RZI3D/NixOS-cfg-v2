{ self, inputs, ... }:
{
  flake.nixosModules.virtualisation =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      virtualisation.docker = {
        # Consider disabling the system wide Docker daemon
        enable = true;
        storageDriver = "btrfs";
        rootless = {
          enable = true;
          setSocketVariable = true;
          # Optionally customize rootless Docker daemon settings
          # daemon.settings = {
          #   dns = [
          #     "1.1.1.1"
          #     "8.8.8.8"
          #   ];
          #   registry-mirrors = [ "https://mirror.gcr.io" ];
          # };
        };
      };
      #virtualisation.virtualbox.host.enable = true;
      #virtualisation.virtualbox.host.enableExtensionPack = true;
      users.extraGroups.vboxusers.members = [ "zackariyyasattaur" ];
      environment.systemPackages = with pkgs; [
        docker-compose
      ];
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = true;
    };
}
