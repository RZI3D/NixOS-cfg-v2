{
  inputs,
  pkgs,
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
  # TODO: re-enable cachy kernel when https://github.com/xddxdd/nix-cachyos-kernel/issues/110 gets resolved
  rzi.kernels.cachyos.enable = false;
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 512; # optional but helps too
    };
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.zpool=zsmalloc"
      "pci=noaer"
    ];
  };

  # Memory & Swap configuration
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 8GB - plenty for a 32GB RAM system
    }
  ];

  # Nix configuration
  nix.generateRegistryFromInputs = true; # Fixes `error: attribute 'self' missing` in flake-utils-plus
  programs.tack.enable = true;
  programs.nh.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];
  nix.settings.trusted-users = [
    "root"
    "zackariyyasattaur"
  ];
  # Binary cache for the Noctalia packages
  nix.settings.substituters = [
    "https://noctalia.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
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
  rzi.niri.enable = true; # backup compositor while Umbriel is still beta
  rzi.noctalia.greeter.enable = true;
  rzi.virtualization.enable = true;
  rzi.games.enable = true;
  rzi.network-analysis.enable = true;

  # Fonts (were in the old host configuration)
  fonts.packages = with pkgs; [
    rubik
    monocraft
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    material-symbols
    google-fonts
  ];

  # Desktop / input services
  services.libinput.enable = true;
  # Do not power the machine off on the power button; the compositor binds
  # XF86PowerOff to the Noctalia session panel instead.
  services.logind.settings.Login.HandlePowerKey = "ignore";
  services.geoclue2.enable = true; # Night light/location
  security.pam.services.login.kwallet.enable = true;

  # Devices & remote access
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };
  services.sunshine = {
    enable = true;
    autoStart = true; # optional: starts Sunshine automatically on login
    capSysAdmin = true;
    openFirewall = true;
  };

  virtualisation.waydroid.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];

  environment.systemPackages = with pkgs; [
    catppuccin-sddm
    evtest
    libwebp
    pkgs.rzi.iloader-latest
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

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

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
      rzi.hplip-patched
    ];
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
