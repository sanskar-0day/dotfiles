{ config, pkgs, unstable, ... }:
{
  # ── Local AI Infrastructure (Ollama + Open WebUI) ─────────────

  environment.systemPackages = with pkgs; [
    unstable.llama-cpp-vulkan
  ];

  # ── Direct llama.cpp Backend ──────────────────────────────────
  # Replacing Ollama with a native llama-server to support the Qwen 3.5 architecture
  # Hosts the exact same 11434 endpoint so Open WebUI doesn't notice the difference.
  systemd.services.llama-cpp = {
    enable = true;
    description = "llama.cpp API Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      # 35B Model downloaded by the user (starts by default, others selectable in UI)
      ExecStart = ''
        ${unstable.llama-cpp-vulkan}/bin/llama-server \
          --models-dir /home/sanskar/models \
          --model /home/sanskar/models/Qwen3.5-35B.gguf \
          --alias "Qwen3.5-35B" \
          --host 127.0.0.1 \
          --port 11434 \
          --n-gpu-layers 25 \
          --ctx-size 8192
      '';
      Restart = "always";
      RestartSec = "3";
      User = "sanskar";
      Group = "users";
      ProtectHome = pkgs.lib.mkForce false; # Allow reading the model from ~/Downloads
    };
  };

  # Open WebUI (Beautiful local ChatGPT clone)
  services.open-webui = {
    enable = false; # Disabled in favor of llama-server's lightweight built-in UI
    port = 8080;
    host = "127.0.0.1";

    # Point WebUI to local llama-server via OpenAI API compatibility
    environment = {
      ENABLE_OLLAMA_API = "False";
      ENABLE_OPENAI_API = "True";
      OPENAI_API_BASE_URL = "http://127.0.0.1:11434/v1";
      OPENAI_API_KEY = "llama.cpp"; # Dummy key
      
      # Privacy/Telemetry
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
      
      # Required for newer Open WebUI versions to bind properly
      WEBUI_AUTH = "False"; # Disables generic login so you can just use it instantly
    };
  };
}
