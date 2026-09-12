{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.rzi.hermes;
in
{
  options.rzi.hermes.enable = lib.mkEnableOption "Hermes Agent (nixosModule)";

  imports = [ inputs.hermes-agent.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "hermes-env/TOKENHARBOR_API_KEY" = { };
      "hermes-env/TOKENHARBOR_API_KEY2" = { };
      "hermes-env/UNOROUTER_API_KEY" = { };
      "hermes-env/DISCORD_BOT_TOKEN" = { };
    };

    sops.templates."hermes-env".content = ''
      TOKENHARBOR_API_KEY=${config.sops.placeholder."hermes-env/TOKENHARBOR_API_KEY2"}
      UNOROUTER_API_KEY=${config.sops.placeholder."hermes-env/UNOROUTER_API_KEY"}
      DISCORD_BOT_TOKEN=${config.sops.placeholder."hermes-env/DISCORD_BOT_TOKEN"}
      DISCORD_ALLOW_ALL_USERS=true
    '';

    services.hermes-agent = {
      enable = true;
      container.enable = true;
      container.backend = "podman";
      container.image = "docker.io/library/ubuntu:24.04";

      # backend.mode = "dashboard";
      # backend.host = config.networking.hostName; # Tailscale hostname thing

      settings = {
        group_sessions_per_user = false;

        discord = {
          auto_thread = false;
          channel_prompts = {
            "1513261440188813412" = "This channel is for DND and TTRPG games. You are the DM/GM.";
          };
        };
        gateway = {
          platforms = {
            discord = {
              extra = {
                allow_admin_from = [
                  "1070455272105054249"
                ];
                # optional: restrict non-admins to specific slash commands
                # user_allowed_commands = [ "status" "model" "history" ];
              };
            };
          };
        };
        # Named custom provider
        providers = {
          tokenharbor = {
            api = "https://tokenharbor.ai/v1";
            key_env = "TOKENHARBOR_API_KEY"; # or OPENAI_API_KEY
            transport = "chat_completions"; # OpenAI-compatible
          };
          unorouter = {
            api = "https://api.unorouter.com/v1";
            key_env = "UNOROUTER_API_KEY";
            transport = "chat_completions"; # OpenAI-compatible
          };
        };

        model = {
          provider = "unorouter"; # points at the named provider above
          default = "glm-5.3-flash-thinking:free";
        };

        agent = {
          reasoning_effort = "none";
        };
      };
      extraDependencyGroups = [ "messaging" ];

      # Secrets (Discord token, LLM keys, etc.)
      environmentFiles = [
        # Preferred with sops-nix / agenix:
        config.sops.templates."hermes-env".path
      ];

      addToSystemPackages = true; # puts `hermes` on PATH
      container.hostUsers = [ "rzi" ]; # creates ~/.hermes symlink for your user
    };
  };
}
