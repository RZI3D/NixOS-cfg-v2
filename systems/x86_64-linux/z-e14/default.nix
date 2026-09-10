{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./igpu.nix
    ./fans.nix
    inputs.sops-nix.nixosModules.sops
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # Bootloader & Kernel configuration
  rzi.kernels.cachyos.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512; # optional but helps too
  };
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.zpool=zsmalloc"
    "pci=noaer"
  ];

  # Memory & Swap configuration
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 8GB - plenty for a 32GB RAM system
    }
  ];

  # Nix configuration
  nixpkgs.config.allowUnfree = true;
  nix.generateRegistryFromInputs = true; # Fixes `error: attribute 'self' missing` in flake-utils-plus
  programs.tack.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  # Networking configuration
  networking.hostName = "z-e14";
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [
    22
    8080 # For testing stuff
  ];

  # User & Environment configuration
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  users.users.zackariyyasattaur = {
    isNormalUser = true;
    description = "Zackariyya Sattaur";
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "uinput"
      "dialout"
      "tty"
      "libvirtd"
      "docker"
      "kvm"
      "wireshark"
    ];
    shell = pkgs.nushell;
    hashedPassword = "$6$rkp83G7XDj8weVI9$hEwyG/13SqUrYvIQc3ZT7/vpvEAGDRvHew47DM2w0Lw44xxVC8YXqHUlNUxEX0VxIdRq6fivmWILvrsODXVoA/";
  };

  rzi.corepkgs.enable = true;
  rzi.umbriel.enable = true;

  # Sound configuration
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

  # Bluetooth configuration
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  hardware.uinput.enable = true; # Trackpad support

  # General services
  services.dbus.enable = true;
  services.gvfs.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "zackariyyasattaur";
    dataDir = "/home/zackariyyasattaur"; # default location for new folders
    configDir = "/home/zackariyyasattaur/.config/syncthing";
  };

  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
      "com.modrinth.ModrinthApp"
    ];
    # optional: prunes anything not declared here on rebuild
    uninstallUnmanaged = true;
  };

  #TODO: The following werent added beacause they need to be migrated to HM
  # proton-vpn

  system.stateVersion = "26.05"; # Do NOT change
}
