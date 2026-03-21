{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Required for the GPU to truly power down when not in use (Silence!)
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  # Custom script to launch apps on NVIDIA with extreme performance & stability flags
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_DESTINATION=NVIDIA
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      export __GL_THREADED_OPTIMIZATIONS=1
      export __GL_SHADER_DISK_CACHE=1
      export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
      # Stability: Prevent driver from CPU-spinning to death on 100% load
      export __GL_YIELD=USLEEP
      # Stability: Prevent frame queue crashes
      export __GL_MaxFramesAllowed=1
      exec gamemoderun "$@"
    '')
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver # existing — keep

      # ── AMD iGPU (KWin + Vulkan translation layer) ──────────
      rocmPackages.clr.icd # OpenCL — needed by some games/DX12 titles
      amdvlk # AMD official Vulkan alongside Mesa radv

      # ── Vulkan infrastructure ────────────────────────────────
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer

      # ── Video decode (game cutscenes, Firefox, VLC) ──────────
      libva
      libva-utils
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      # 32-bit Vulkan for older games and Wine
      vulkan-loader
      amdvlk
    ];
  };
}
