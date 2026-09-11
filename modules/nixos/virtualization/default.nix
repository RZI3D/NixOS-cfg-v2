{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.rzi.virtualization;
in
{
  options.rzi.virtualization.enable = lib.mkEnableOption "Virtualization (nixosModule)";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

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