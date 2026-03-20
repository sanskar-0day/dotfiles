{
  config,
  pkgs,
  unstable,
  ...
}:
{
  # ── Local AI Infrastructure (LM Studio) ───────────────────────
  environment.systemPackages = [
    # Include the base package so desktop entries/icons exist
    unstable.lmstudio

    # Performance wrapper for NVIDIA PRIME
    (pkgs.writeShellScriptBin "lmstudio-nvidia" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_DESTINATION=NVIDIA
      export __VK_LAYER_NV_optimus=NVIDIA_only
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __GL_THREADED_OPTIMIZATIONS=1
      export __GL_SHADER_DISK_CACHE=1
      export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
      export __GL_YIELD=USLEEP
      export __GL_MaxFramesAllowed=1
      export CUDA_CACHE_DISABLE=0
      # Use gamemoderun for max clocks and the unstable binary for the heavy lifting
      exec gamemoderun ${unstable.lmstudio}/bin/lmstudio "$@"
    '')
  ];
}
