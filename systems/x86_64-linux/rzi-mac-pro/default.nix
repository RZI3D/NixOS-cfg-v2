{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./rx580.nix
    inputs.sops-nix.nixosModules.sops
    # games / home-manager / llama-swap / minecraft-servers / selfhosted are all
    # auto-discovered under modules/nixos and toggled with `rzi.*.enable` below.
  ];

  nixpkgs.overlays = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  networking.hostName = "rzi-mac-pro";
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose"; # Exit Node fix
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];
  nix.generateRegistryFromInputs = true;

  rzi.games.enable = true;
  rzi.llama-swap.enable = true;
  rzi.selfhosted.enable = true;
  rzi.minecraft-servers.enable = true;
  rzi.hermes.enable = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  programs.corectrl.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    mcrcon
    blender
  ];

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "rzi";
    dataDir = "/home/rzi"; # default location for new folders
    configDir = "/home/rzi/.config/syncthing";
  };

  services.desktopManager.plasma6.enable = true;
  xdg.portal.extraPortals = [
    pkgs.kdePackages.xdg-desktop-portal-kde
  ];

  # Enable the X11 windowing system (needed for SDDM even on Wayland)
  services.xserver.enable = true;

  # Enable SDDM and Hyprland

  services.displayManager = {

    autoLogin.enable = true;
    autoLogin.user = "rzi";

    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha-mauve";
      extraPackages = with pkgs.kdePackages; [
        qt5compat
        qtdeclarative
        qtsvg
      ];
    };
  };

  programs.fish.enable = true;

  users.users.rzi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
    ];
    shell = pkgs.fish;
    hashedPassword = "$6$OvnYl4fZQAvjeabE$EsDp260VXyumFBPEpKjSwaul8VszF9qnh9JHTvTNyopLuXk6UGdGsv4UWz5/JOXwap1KdjrhhnSukoClbhX1.1";
  };

  services.sunshine = {
    enable = true;
    autoStart = true; # optional: starts Sunshine automatically on login
    capSysAdmin = true;
    openFirewall = true;
  };

  # home-manager.users.rzi = inputs.self.homeModules.rziModule;
  # home-manager.backupFileExtension = "bkp";
  # home-manager.overwriteBackup = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  sops = {
    defaultSopsFile = ../../../secrets/rzi-mac-pro/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/rzi/.config/sops/age/keys.txt";
    secrets = {
      "playit-secret" = { };
    };
  };

  networking.firewall.allowedTCPPortRanges = [
    {
      from = 5555;
      to = 5560;
    } # for multiuser server
  ];

  networking.firewall.allowedTCPPorts = [
    22
    8080
    3000
    6333
    6334
    8006 # Zackariyya's Open Terminal
    8007 # Royan's Open Terminal
    25565 # Minecraft
  ];
  networking.firewall.allowedUDPPorts = [
    25565 # Minecraft
    24454 # MC Voice Chat
    48372 # Playit VC -  Survival
    24455 # MC Creative Voice Chat
  ];

  system.stateVersion = "26.05";
}
