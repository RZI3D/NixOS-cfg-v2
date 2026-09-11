{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rzi.llama-swap;

  # Use the Vulkan-enabled versions of llama.cpp / stable-diffusion.cpp
  llama-cpp-vulkan = pkgs.llama-cpp.override { vulkanSupport = true; };
  sd-cpp-vulkan = pkgs.stable-diffusion-cpp.override { vulkanSupport = true; };

  llm-args = "
  --port \${PORT}
  --flash-attn on
  -ctk q8_0
  -ctv q8_0
  -c 64000";

  big-llm-args = "
  --port \${PORT}
  --flash-attn on
  -ctk iq4_nl
  -ctv iq4_nl";
in
{
  options.rzi.llama-swap.enable = lib.mkEnableOption "llama-swap model server (nixosModule)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      llama-cpp-vulkan # so i can use it in the terminal if i want
      sd-cpp-vulkan # same here
    ];

    services.llama-swap = {
      enable = true;
      openFirewall = true;
      listenAddress = "0.0.0.0";
      port = 8090;
      settings = {
        healthCheckTimeout = 60;
        models = {
          # 1. The Speed Model (100% GPU)
          "qwen2.5-coder-7b" = {
            cmd = "${llama-cpp-vulkan}/bin/llama-server 
            -m /var/lib/llama/models/qwen2.5-coder-7b-instruct-q5_k_m.gguf 
            -ngl 99
            --jinja ${llm-args}";
          };

          "qwen3-14b" = {
            cmd = "${llama-cpp-vulkan}/bin/llama-server
              -m /var/lib/llama/models/Qwen3-14B-UD-Q4_K_XL.gguf
              --ctx-size 32768
              --jinja
              -ngl 32 ${llm-args}";
          };

          "gemma4-e4b" = {
            cmd = "${llama-cpp-vulkan}/bin/llama-server 
            --model /var/lib/llama/models/gemma-4-E4B-it-Q4_K_M.gguf
            --mmproj /var/lib/llama/models/gemma-4-E4B-it-mmproj-F16.gguf
            -ngl 50 
            --jinja ${llm-args}";
          };

          "gemma4-26b-a4b-heretic" = {
            cmd = "${llama-cpp-vulkan}/bin/llama-server
              -m /var/lib/llama/models/gemma-4-26B-A4B-it-uncensored-heretic-Q4_K_M.gguf
              --ctx-size 32768
              --jinja
              -ngl 20
              --threads 10 ${llm-args}";
          };

          "z-image-turbo" = {
            cmd = "${sd-cpp-vulkan}/bin/sd-server -l 0.0.0.0 --listen-port \${PORT} 
            --diffusion-model /var/lib/llama/models/z-image-turbo-Q4_K_M.gguf
            --llm /var/lib/llama/models/Qwen3-4B-Q4_K_M.gguf 
            --vae /var/lib/llama/models/z-image-turbo.safetensors 
            --threads 4 --cfg-scale 1.0 --steps 8
            --clip-on-cpu 
            --vae-tiling";
            checkEndpoint = "/";
          };

          "bge-m3" = {
            cmd = "${llama-cpp-vulkan}/bin/llama-server 
            -m /var/lib/llama/models/bge-m3-q8_0.gguf 
            -ngl 99 
            --embedding 
            --pooling mean
            -b 2048 
            -ub 2048
            --port \${PORT}";
          };
        };
      };
    };

    systemd.services.llama-swap.serviceConfig = {
      User = "llama";
      Group = "llama";
    };

    users.users.llama = {
      isSystemUser = true;
      group = "llama";
      extraGroups = [
        "video"
        "render"
      ];
      home = "/var/lib/llama";
      createHome = true;
    };
    users.groups.llama = { };

    virtualisation.oci-containers.containers = {
      "kokoro-tts" = {
        image = "ghcr.io/eduardolat/kokoro-web:latest";
        ports = [ "8880:3000" ];
        environment = {
          KW_SECRET_API_KEY = "supercoolmacpro2012";
        };
      };

      "terminal-zackariyya" = {
        image = "ghcr.io/open-webui/open-terminal:latest";
        ports = [ "8006:8000" ];
        volumes = [ "/var/lib/open-terminal-home/zackariyya:/home" ];
        environment = {
          OPEN_TERMINAL_API_KEY = "zackariyya-open-term-828";
        };
        extraOptions = [
          "--cap-add=NET_RAW"
          "--cap-add=NET_ADMIN"
        ];
      };

      "terminal-royan" = {
        image = "ghcr.io/open-webui/open-terminal:latest";
        ports = [ "8007:8000" ];
        volumes = [ "/var/lib/open-terminal-home/royan:/home" ];
        environment = {
          OPEN_TERMINAL_API_KEY = "royan-open-terminal-911";
        };
        extraOptions = [
          "--cap-add=NET_RAW"
          "--cap-add=NET_ADMIN"
        ];
      };
    };
  };
}
