{ self, inputs, ...}: {

    flake.nixosModules.z-e14Hardware =  { config, lib, pkgs, modulesPath, ... }: {
        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = [
            "xhci_pci"
            "ahci"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" = {
            device = "/dev/disk/by-uuid/4e5d055a-6b27-4f2b-b0c9-6d1cce2b963f";
            fsType = "btrfs";
            options = [ "subvol=@nixos" ];
        };

        fileSystems."/nix" = {
            device = "/dev/disk/by-uuid/4e5d055a-6b27-4f2b-b0c9-6d1cce2b963f";
            fsType = "btrfs";
            options = [
            "subvol=@nix"
            "compress=zstd"
            "noatime"
            ];
        };

        fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/7757-64AF";
            fsType = "vfat";
            options = [
            "fmask=0077"
            "dmask=0077"
            ];
        };

        fileSystems."/home" = {
            device = "/dev/disk/by-uuid/4e5d055a-6b27-4f2b-b0c9-6d1cce2b963f";
            fsType = "btrfs";
            options = [ "subvol=@nixos_home" ];
        };

        fileSystems."/mnt/DATA" = {
            device = "/dev/disk/by-uuid/4e5d055a-6b27-4f2b-b0c9-6d1cce2b963f";
            fsType = "btrfs";
            options = [ "subvol=@data" ];
        };

        swapDevices = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}
