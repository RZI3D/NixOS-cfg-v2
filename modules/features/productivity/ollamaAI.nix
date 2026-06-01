{ self, inputs, ... }:
{
  flake.nixosModules.ollamaAI =
    { ... }:
    {
      services.ollama.enable = true;
      services.ollama.environmentVariables.OLLAMA_NUM_THREADS = "8";
      services.ollama.loadModels = [
#         "phi4:14b"
#         "qwen2.5-coder:7b-instruct-q4_K_M"
#         "deepseek-r1:7b"
        "mxbai-embed-large:335m"
      ];
    };
}
