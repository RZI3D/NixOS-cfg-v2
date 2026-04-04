{ self, inputs, ... }:
{

  flake.nixosModules.z-e14Configuration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      imports = with self.nixosModules; [
        z-e14Hardware
        self.overlays.patched-pkgs # Patched qt6ct and colloid

        homeManager
        ai
        browsers
        productivityCommon
        communication
        creativity
        notes
        office
        ffWebApps
      ];

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 5;
      networking.hostName = "z-e14-nix"; # Define your hostname.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Asia/Riyadh";

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";
      # console = {
      #   font = "Lat2-Terminus16";
      #   keyMap = "us";
      #   useXkbConfig = true; # use xkb.options in tty.
      # };

      # Enable the X11 windowing system.
      # services.xserver.enable = true;

      # Configure keymap in X11
      # services.xserver.xkb.layout = "us";
      # services.xserver.xkb.options = "eurosign:e,caps:escape";

      # Enable CUPS to print documents.
      # services.printing.enable = true;

      # Enable sound.
      # services.pulseaudio.enable = true;
      # OR
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;

      hardware.bluetooth.enable = true;
      # services.mpris-proxy.enable = true;
      hardware.bluetooth.settings = {
        General = {
          Experimental = true;
        };
      };

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.zackariyyasattaur = {
        isNormalUser = true;
        description = "Zackariyya Sattaur";
        extraGroups = [
          "wheel"
          "networkmanager"
        ]; # Enable ‘sudo’ for the user.
        hashedPassword = "$6$rkp83G7XDj8weVI9$hEwyG/13SqUrYvIQc3ZT7/vpvEAGDRvHew47DM2w0Lw44xxVC8YXqHUlNUxEX0VxIdRq6fivmWILvrsODXVoA/";
      };
      home-manager.users.zackariyyasattaur = self.homeModules.zackariyyasattaurModule;

      # Enable the X11 windowing system (needed for SDDM even on Wayland)
      services.xserver.enable = true;

      # Enable SDDM and Hyprland

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "catppuccin-mocha-mauve";
        extraPackages = with pkgs.kdePackages; [
          qt5compat
          qtdeclarative
          qtsvg
        ];
      };
      services.desktopManager.plasma6.enable = true;
      xdg.portal.extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
      programs.hyprland.enable = true;

      services.upower.enable = true; # Battery info
      services.geoclue2.enable = true; # Night light/location
      services.gvfs.enable = true; # File manager mounting
      services.dbus.enable = true;
      security.pam.services.login.kwallet.enable = true;

      fonts.packages = with pkgs; [
        rubik
        nerd-fonts.ubuntu
        nerd-fonts.jetbrains-mono
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        material-symbols # Essential for his icons
      ];

      # Allow unfree for some of his recommended tools
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        git
        python3 # Used for various scripts
        kdePackages.plasma-workspace-wallpapers
        catppuccin-sddm

        # Desktop Components
        swww # Wallpaper daemon
        brightnessctl # Backlight control
        wl-clipboard # Copy/Paste
        libwebp # For image processing
        # Audio/Media
        wireplumber
        playerctl
        curl
        kdePackages.kwallet
        kdePackages.kwalletmanager
        kdePackages.kwallet-pam
      ];

      services.qdrant = {
        enable = true;
        # Listens on 127.0.0.1 by default.
        # Set to "0.0.0.0" if you need access from other machines/containers.
        settings = {
          service = {
            host = "127.0.0.1";
            http_port = 6333;
            grpc_port = 6334;
          };
          storage = {
            storage_path = "/var/lib/qdrant/storage";
          };
        };
      };

      services.dbus.packages = [ pkgs.kdePackages.kwallet ];
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true; # Set to false later once you add your SSH keys
          PermitRootLogin = "no"; # Arch security best practice
        };
      };

      # Open ports in the firewall.
      networking.firewall.allowedTCPPorts = [ 22 ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # This option defines the first version of NixOS you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new NixOS release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current NixOS release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "26.05"; # Did you read the comment?

    };

}
