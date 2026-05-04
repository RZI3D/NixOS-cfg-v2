{ self, inputs, ... }:
{

  # This is your module that imports and configures home-manager
  flake.nixosModules.howdyAuth =
    { pkgs, ... }:
    {
      # 1. Enable the Howdy Service
      services.howdy = {
        enable = true;
        settings = {
          video.device_path = "/dev/video0";
          core = {
            dark_threshold = 100;
          };
          video.recording_adapter = "ffmpeg";
        };
      };

      # 2. Enable PAM module
      security.pam.howdy.enable = true;

      # 3. Set as "sufficient" (Face OR Password)
      # This tells PAM: "If face works, stop here. If not, ask for password."
      security.pam.services = {
        sudo.howdy.control = "sufficient";
        login.howdy.control = "sufficient";

        # If you use a specific Desktop Manager, add it here:
        sddm.howdy.control = "sufficient";
        # gdm-password.howdy.control = "sufficient";
        # swaylock.howdy.control = "sufficient";
      };
    };
}
