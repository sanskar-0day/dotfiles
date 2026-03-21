{
  config,
  pkgs,
  unstable,
  ...
}:
{
  # ── Local AI Infrastructure (LM Studio) ───────────────────────
  environment.systemPackages = [
    # Base package (provides desktop entries and shared libraries)
    unstable.lmstudio

    # ── NVIDIA Offload Wrapper ──
    # Forces LM Studio to use the NVIDIA dGPU for CUDA-accelerated inference.
    # Also applies NVIDIA threaded optimizations and cache tweaks for better token speed.
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
      # Combine with GameMode for maximum GPU clocks
      exec gamemoderun ${unstable.lmstudio}/bin/lmstudio "$@"
    '')
  ];
}
