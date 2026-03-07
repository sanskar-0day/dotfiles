{ config, pkgs, unstable, ... }:
{
  # ── Local AI Infrastructure (Ollama + Open WebUI) ─────────────

  environment.systemPackages = with pkgs; [
    unstable.llama-cpp
  ];

  # Start Ollama service (CPU/Auto-detect to avoid 40m source compilation)
  services.ollama = {
    enable = true;
    package = unstable.ollama-cuda; # Pull cutting-edge version for Qwen 3.5 support
    
    # Allow local connections
    host = "127.0.0.1";
    port = 11434;
  };

  # Override systemd sandbox so it can actually read the user's files
  systemd.services.ollama = {
    serviceConfig = {
      User = pkgs.lib.mkForce "sanskar";
      Group = pkgs.lib.mkForce "users";
      DynamicUser = pkgs.lib.mkForce false; # Disable the random UID sandbox
      ProtectHome = pkgs.lib.mkForce false; # Allow reading ~/.ollama
    };
  };

  # Open WebUI (Beautiful local ChatGPT clone)
  services.open-webui = {
    enable = true;
    port = 8080;
    host = "127.0.0.1";

    # Point WebUI to local Ollama and disable telemetry
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      # You can enable OpenAI API later if you want to use external keys
      ENABLE_OPENAI_API = "False";
      
      # Privacy/Telemetry
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
      
      # Required for newer Open WebUI versions to bind properly
      WEBUI_AUTH = "False"; # Disables generic login so you can just use it instantly
    };
  };
}
