{ config, pkgs, ... }:
{
  # ── Wine (Windows compatibility layer) ─────────────────────────
  # wineWowPackages.stagingFull = 64-bit + 32-bit Wine Staging
  # (better game compatibility than vanilla Wine)
  environment.systemPackages = with pkgs; [
    # Wine Staging (best for games — includes experimental patches)
    wineWowPackages.stagingFull

    # Essential Wine tools
    winetricks          # Install Windows deps (DirectX, .NET, Visual C++, etc.)

    # Game launchers (pick your weapon)
    lutris              # Runs any Windows game with auto Wine/DXVK setup
    bottles             # Modern Wine prefix manager — easy "one-click" installs
    heroic              # Epic Games / GOG launcher for Linux

    # Performance
    mangohud            # FPS overlay (Vulkan/OpenGL)
    gamemode            # Feral's CPU/GPU optimizer — auto-enabled by Lutris

    # Vulkan support (required for DXVK — translates DirectX 9/10/11 → Vulkan)
    vulkan-tools
    vulkan-loader
  ];

  # ── 32-bit support (required for most Windows games) ──────────
  hardware.graphics.enable32Bit = true;

  # ── GameMode service ──────────────────────────────────────────
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;                # Prioritize game process
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };

  # ── Steam (already enabled, adding Proton extras) ─────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;   # Gamescope compositor for better perf
  };

  # ── Gamescope (micro-compositor for games) ────────────────────
  programs.gamescope = {
    enable = true;
    capSysNice = true;  # Allow priority scheduling
  };
}
