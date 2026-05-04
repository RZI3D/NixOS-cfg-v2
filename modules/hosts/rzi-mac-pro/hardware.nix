{ self, inputs, ... }:
{
  flake.nixosModules.rziMacProHardware =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      # You'll replace this whole file after running
      # nixos-generate-config on the target machine!
      boot.initrd.availableKernelModules = [
        "uhci_hcd"
	"ehci_pci"
	"ahci"
	"xhci_pci"
	"firewire_ohci"
	"usbhid"
	"usb_storage"
	"sd_mod"
	"sr_mod"
      ];
      boot.kernelModules = [
        "kvm-intel"
        "amdgpu"
      ];

      # Fill these in after install
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/37d784f6-089e-4f43-85ae-90da6ad859ba";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/25A5-D7CD";
        fsType = "vfat";
	options = [ "fmask=0077" "dmask=0077" ];
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
