{ config, pkgs, unstable, ... }:
{
  # ── Local AI Infrastructure (LM Studio) ───────────────────────

  environment.systemPackages = with pkgs; [
    (symlinkJoin {
      name = "lmstudio-nvidia";
      paths = [ unstable.lmstudio ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/lm-studio \
          --set __NV_PRIME_RENDER_OFFLOAD 1 \
          --set __VK_LAYER_NV_optimus NVIDIA_only \
          --set __GLX_VENDOR_LIBRARY_NAME nvidia
      '';
    })

    # AI Autonomous Agent
    unstable.openclaw
  ];
}
