{ self, inputs, ...}: {

    flake.nixosModules.z-thinktabHardware =  { config, lib, pkgs, modulesPath, ... }: {
        imports =
            [ (modulesPath + "/installer/scan/not-detected.nix")
            ];

        boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_acpi" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" =
            { device = "/dev/disk/by-uuid/eeaac3c1-07a7-4b6e-9ffe-90830623712b";
            fsType = "btrfs";
            options = [ "subvol=@root" ];
            };

        fileSystems."/nix" =
            { device = "/dev/disk/by-uuid/eeaac3c1-07a7-4b6e-9ffe-90830623712b";
            fsType = "btrfs";
            options = [ "subvol=@nix" ];
            };

        fileSystems."/home" =
            { device = "/dev/disk/by-uuid/eeaac3c1-07a7-4b6e-9ffe-90830623712b";
            fsType = "btrfs";
            options = [ "subvol=@home" ];
            };

        fileSystems."/boot" =
            { device = "/dev/disk/by-uuid/8CD7-2252";
            fsType = "vfat";
            options = [ "fmask=0022" "dmask=0022" ];
            };

        swapDevices = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}
