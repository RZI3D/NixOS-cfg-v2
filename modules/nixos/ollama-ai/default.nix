{
  lib,
  config,
  ...
}:
let
  cfg = config.rzi.ollama-ai;
in
{
  options.rzi.ollama-ai.enable = lib.mkEnableOption "Ollama (nixosModule)";

  config = lib.mkIf cfg.enable {
    services.ollama.enable = true;
    services.ollama.environmentVariables.OLLAMA_NUM_THREADS = "8";
    services.ollama.loadModels = [
      "mxbai-embed-large:335m"
    ];
  };
}
