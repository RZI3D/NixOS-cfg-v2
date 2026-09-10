{
  config,
  lib,
  pkgs,
  ...
}:
{

  boot.kernelParams = [ "thinkpad_acpi.fan_control=1" ];
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
      ]
      [
        4
        55
        68
      ]
      [
        6
        63
        78
      ]
      [
        7
        73
        88
      ]
      [
        "level full-speed"
        83
        32767
      ] # Thats pretty hot!
    ];
  };
}
