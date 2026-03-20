{ config, pkgs, ... }:
{
  # ── Wine (Windows compatibility layer) ─────────────────────────
  # wineWowPackages.stagingFull = 64-bit + 32-bit Wine Staging
  # (better game compatibility than vanilla Wine)
  environment.systemPackages = with pkgs; [
    # Wine Staging (best for games — includes experimental patches)
    wineWowPackages.stagingFull
    winetricks

    # Game launchers
    lutris
    bottles
    heroic              # Epic Games / GOG launcher

    # Performance
    mangohud            # FPS overlay (Vulkan/OpenGL)
    gamemode            # Feral's CPU/GPU optimizer
    libstrangle         # FPS capping tool (prevents stutters)
    
    # Steam helpers
    protontricks        # Winetricks for Proton games (essential for many games)
    steam-run           # Run anything inside the Steam environment (FHS)
    
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
        renice = 15;                # Higher prioritize for game process
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermode_offset = 1;    # Set NVIDIA to "Prefer Maximum Performance"
      };
      # Custom scripts when starting/stopping gamemode
      custom = {
        start = "notify-send 'GameMode' 'Turbo Active - GPU Max Performance'";
        stop = "notify-send 'GameMode' 'Turbo Disabled - Resetting'";
      };
    };
  };

  # ── Ananicy (Auto-Nice) ───────────────────────────────────────
  # Automatically prioritizes games and heavy apps in the background
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # ── Steam (already enabled, adding Proton extras) ─────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;   # Gamescope compositor for better perf
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # ── Gamescope (micro-compositor for games) ────────────────────
  programs.gamescope = {
    enable = true;
    capSysNice = true;  # Allow priority scheduling
  };

  # ── Wine / FitGirl Repack memory fixes ───────────────────────
  # FitGirl's Oodle decompressor needs huge stack + memory mappings
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;  # Wine needs lots of memory mappings
    "fs.file-max" = 524288;           # Prevent "too many open files" crashes in huge games
  };
  security.pam.loginLimits = [
    { domain = "*"; type = "hard"; item = "stack"; value = "unlimited"; }
    { domain = "*"; type = "soft"; item = "stack"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
    { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
  ];
}
