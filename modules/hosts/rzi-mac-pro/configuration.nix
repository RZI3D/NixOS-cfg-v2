{ self, inputs, ... }:
{
  flake.nixosModules.rziMacProConfiguration =
    { pkgs, lib, ... }:
    {
      imports = with self.nixosModules; [
        rziMacProHardware
        homeManager
        llamaSwap
      ];
      nixpkgs.overlays = [
        self.overlays.patched-pkgs
        inputs.nix4vscode.overlays.default
        # inputs.dolphin-overlay.overlays.default
      ];
      boot.loader.grub.enable = true;
      boot.loader.grub.efiSupport = true;
      boot.loader.grub.efiInstallAsRemovable = true;
      boot.loader.grub.device = "nodev";

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
      ];
      nixpkgs.config.allowUnfree = true;

      # Vulkan for RX 580
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          mesa
          vulkan-loader
          vulkan-tools
        ];
      };
      boot.initrd.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "amdgpu" ];
      boot.kernelParams = [
        "amdgpu.gpu_recovery=1"
        "amdgpu.lockup_timeout=10000"
      ];
      hardware.amdgpu.overdrive.enable = true;
      programs.corectrl.enable = true;
      environment.systemPackages = with pkgs; [
        git
        htop
        # lact
        radeontop
        amdgpu_top
      ];
      # systemd.services.lact = {
      #   description = "AMDGPU Control Daemon";
      #   after = [ "multi-user.target" ];
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     ExecStart = "${pkgs.lact}/bin/lact daemon";
      #   };
      #   enable = true;
      # };
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

      users.users.zackariyyasattaur = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "render"
        ];
        hashedPassword = "$6$rkp83G7XDj8weVI9$hEwyG/13SqUrYvIQc3ZT7/vpvEAGDRvHew47DM2w0Lw44xxVC8YXqHUlNUxEX0VxIdRq6fivmWILvrsODXVoA/"; # same as laptop
      };
      users.users.rzi = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "render"
        ];
        hashedPassword = "$6$OvnYl4fZQAvjeabE$EsDp260VXyumFBPEpKjSwaul8VszF9qnh9JHTvTNyopLuXk6UGdGsv4UWz5/JOXwap1KdjrhhnSukoClbhX1.1";
      };

      home-manager.users.rzi = self.homeModules.rziModule;
      home-manager.backupFileExtension = "bkp";
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = true;
      };

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = ["/var/lib/harmonia/cache-priv-key.pem"];
        settings = {
          # Server Nix store
          virtual_nix_store = "/nix/store";
          # Served Nix store
          real_nix_store = "/var/lib/harmonia/nix/store";
        };
      };

      networking.firewall.allowedTCPPorts = [
        22
        8080
        3000
        6333
        6334
        8006 # Zackariyya's Open Terminal
        8007 # Royan's Open Terminal
      ];

      system.stateVersion = "26.05";
    };
}
