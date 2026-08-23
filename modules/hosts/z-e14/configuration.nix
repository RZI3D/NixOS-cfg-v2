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
        inputs.sops-nix.nixosModules.sops
        inputs.nix-flatpak.nixosModules.nix-flatpak
        homeManager
        #ollamaAI
        games
        #kdePlasma
        rziNiri
        productivityCommon
        virtualisation
        inputs.noctalia-greeter.nixosModules.default
        #howdyAuth
        umbriel

      ];

      programs.nh.enable = true;

      nixpkgs.overlays = [
        self.overlays.patched-pkgs
        inputs.nix4vscode.overlays.default
        inputs.nix-cachyos-kernel.overlays.default
        inputs.dolphin-overlay.overlays.default
        inputs.nixgl.overlay
        inputs.helium-flake.overlays.default
        # Below is fix for betaflight NWJS
        (final: prev: {
          nwjs = prev.nwjs.overrideAttrs {
            version = "0.84.0";
            src = prev.fetchurl {
              url = "https://dl.nwjs.io/v0.84.0/nwjs-v0.84.0-linux-x64.tar.gz";
              hash = "sha256-VIygMzCPTKzLr47bG1DYy/zj0OxsjGcms0G1BkI/TEI=";
            };
          };
        })
      ];

      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

      # Binary cache for CachyOS latest kernel
      nix.settings.substituters = [
        "https://attic.xuyh0120.win/lantian"
        "https://noctalia.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      nix.settings.trusted-users = [
        "root"
        "zackariyyasattaur"
      ];

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.blacklistedKernelModules = [ "apple_mfi_fastcharge" ]; # interferes with palera1n
      boot.kernel.sysctl = {
        "fs.inotify.max_user_watches" = 524288;
        "fs.inotify.max_user_instances" = 512; # optional but helps too
      };
      boot.kernelParams = [
        "zswap.enabled=1"
        "zswap.compressor=zstd"
        "zswap.zpool=zsmalloc"
        "pci=noaer"
        "thinkpad_acpi.fan_control=1"
      ];
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 8 * 1024; # 8GB - plenty for a 32GB RAM system
        }
      ];
      networking.hostName = "z-e14"; # Define your hostname.
      services.tailscale.enable = true;
      networking.firewall.checkReversePath = false;
      services.cloudflare-warp.enable = true;
      #       services.cloudflared = {
      #         enable = true;
      #         tunnels = {
      #           "b765985d-055d-4cc2-940c-fb7393c90aab" = {
      #             credentialsFile = "/var/lib/cloudflared/creds.json";
      #
      #             ingress = {
      #               "pos-staging.rzi.dpdns.org" = "http://127.0.0.1:8069";
      #             };
      #
      #             default = "http_status:404";
      #           };
      #         };
      #       };

      services.usbmuxd = {
        enable = true;
        package = pkgs.usbmuxd2;
      };
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-compute-runtime-legacy1
          vulkan-validation-layers
          intel-media-driver
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };

      services.thinkfan = {
        enable = true;

        sensors = [
          {
            type = "hwmon";
            query = "/sys/class/hwmon/hwmon4/temp1_input";
            #name = "coretemp";
          }
          {
            type = "hwmon";
            query = "/sys/class/hwmon/hwmon5/temp1_input";
            #name = "thinkpad";
          }
        ];

        # [ fan-speed, lower-bound, upper-bound ]
        fans = [
          {
            type = "tpacpi";
            query = "/proc/acpi/ibm/fan";
          }
        ];
        levels = [
          [
            "level auto"
            0
            55
          ]
          [
            2
            48
            60
          ] # Lower start point for more "stickiness"
          [
            4
            55
            68
          ] # Mid-step
          [
            6
            63
            78
          ] # High-step
          [
            7
            73
            88
          ] # Almost max
          [
            "level full-speed"
            83
            32767
          ] # Emergency max
        ];
      };

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;
      # services.dnsmasq.enable = true;

      # Set your time zone.
      time.timeZone = "America/New_York";

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
        alsa.enable = true;
        jack.enable = true;
      };

      services.sunshine = {
        enable = true;
        autoStart = true; # optional: starts Sunshine automatically on login
        capSysAdmin = true;
        openFirewall = true;
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
      hardware.uinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
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
      home-manager.users.zackariyyasattaur = self.homeModules.zackariyyasattaurModuleE14;
      home-manager.backupFileExtension = "bkp";
      # # Enable the X11 windowing system (needed for SDDM even on Wayland)
      # services.xserver.enable = true;

      # # Enable SDDM and Hyprland

      # services.displayManager.sddm = {
      #   enable = true;
      #   wayland.enable = true;
      #   theme = "catppuccin-mocha-mauve";
      #   extraPackages = with pkgs.kdePackages; [
      #     qt5compat
      #     qtdeclarative
      #     qtsvg
      #   ];
      # };

      programs.noctalia-greeter = {
        enable = true;
        settings = {
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
            path = "${pkgs.bibata-cursors}/share/icons";
          };
          keyboard = {
            layout = "us";
          };
        };
      };

      services.upower.enable = true; # Battery info
      services.power-profiles-daemon.enable = true; # Power profiles
      services.geoclue2.enable = true; # Night light/location
      services.gvfs.enable = true; # File manager mounting
      services.dbus.enable = true;
      security.pam.services.login.kwallet.enable = true;

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

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        git
        python3 # Used for various scripts
        #kdePackages.plasma-workspace-wallpapers
        catppuccin-sddm
        evtest
        libnotify
        # Desktop Components
        brightnessctl # Backlight control
        wl-clipboard # Copy/Paste
        libwebp # For image processing
        # Audio/Media
        wireplumber
        playerctl
        usbutils
        curl
        kdePackages.kwallet
        kdePackages.kwalletmanager
        kdePackages.kwallet-pam
        comma
        wireguard-tools
        proton-vpn
        ripgrep
        ffmpeg
        tack

      ];

      virtualisation.waydroid.enable = true;
      virtualisation.waydroid.package = pkgs.waydroid-nftables;

      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        user = "zackariyyasattaur";
        dataDir = "/home/zackariyyasattaur"; # default location for new folders
        configDir = "/home/zackariyyasattaur/.config/syncthing";
      };

      #       services.qdrant = {
      #         enable = true;
      #         # Listens on 127.0.0.1 by default.
      #         # Set to "0.0.0.0" if you need access from other machines/containers.
      #         settings = {
      #           service = {
      #             host = "127.0.0.1";
      #             http_port = 6333;
      #             grpc_port = 6334;
      #           };
      #           storage = {
      #             storage_path = "/var/lib/qdrant/storage";
      #           };
      #         };
      #       };

      services.flatpak = {
        enable = true;
        packages = [
          "org.vinegarhq.Sober"
          "com.modrinth.ModrinthApp"
        ];
        # optional: prunes anything not declared here on rebuild
        uninstallUnmanaged = true;
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
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };

      # Open ports in the firewall.
      networking.firewall.allowedTCPPorts = [
        22
        8080 # Debugging
      ];
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
