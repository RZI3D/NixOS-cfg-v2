{
  self,
  inputs,
  pkgs,
  config,
  ...
}:
{
  flake.nixosModules.llamaSwap =
    { pkgs, config, ... }:
    let
      # Use the Vulkan-enabled version of llama-cpp
      llama-cpp-vulkan = pkgs.llama-cpp.override { vulkanSupport = true; };
      sd-cpp-vulkan = pkgs.stable-diffusion-cpp.override { vulkanSupport = true; };
      # Maybe see when turb quant gets released and add that here
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
      environment.systemPackages = with pkgs; [
        llama-cpp-vulkan # so i can use it in the terminal if i want
        sd-cpp-vulkan # same here
      ];
      #TODO: Add deepseek-coder-v2-lite, gemma-4-26b, z-image-turbo-Q4_K_M.gguf, z-image-Q4_K_M.gguf, qwen-image-edit-2511-Q4_K_M.gguf,
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
              cmd = "${pkgs.llama-cpp-vulkan}/bin/llama-server
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
              # --rng cpu --threads 8 --vae-tiling --llm /var/lib/llama/models/Qwen3-4B-Q4_K_M.gguf --clip-on-cpu --vae-on-cpu
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

#       services.open-webui = {
#         enable = true;
#
#         package = pkgs.open-webui.overridePythonAttrs (old: {
#           propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
#             pkgs.python3Packages.qdrant-client
#           ];
#         });
#
#         port = 3000;
#         host = "0.0.0.0";
#         environment = {
#           OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1";
#           OPENAI_API_KEY = "sk-unused";
#           ENABLE_OLLAMA_API = "False";
#           VECTOR_DB = "qdrant";
#           QDRANT_URI = "http://127.0.0.1:6333";
#           ENABLE_QDRANT_MULTITENANCY_MODE = "True";
#         };
#       };
#
#       systemd.services.open-webui = {
#         serviceConfig = {
#           LimitNOFILE = 65535;
#         };
#       };


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

#       services.qdrant = {
#         enable = true;
#         # Listens on 127.0.0.1 by default.
#         # Set to "0.0.0.0" if you need access from other machines/containers.
#         settings = {
#           service = {
#             host = "0.0.0.0";
#             http_port = 6333;
#             grpc_port = 6334;
#           };
#           storage = {
#             storage_path = "/var/lib/qdrant/storage";
#           };
#         };
#       };

    };
}
