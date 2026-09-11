{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.howdy;
in
{
  options.rzi.howdy.enable = lib.mkEnableOption "Howdy face authentication (nixosModule)";

  config = lib.mkIf cfg.enable {
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
      sddm.howdy.control = "sufficient";
      sshd.howdy.enable = false;
    };
  };
}
