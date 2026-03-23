{ config, pkgs, ... }:
{
  # ── Wine & Windows Compatibility ──────────────────────────────
  # We use stagingFull for the most up-to-date patches for modern games.
  environment.systemPackages = with pkgs; [
    wineWowPackages.stagingFull
    winetricks
    lutris
    bottles
    heroic              # Epic / GOG Launcher
    mangohud            # FPS/Thermal overlay
    gamemode            # Feral's CPU/GPU prioritization daemon
    libstrangle         # FPS capper (essential for variable refresh/sync)
    protontricks        # Winetricks for Steam/Proton
    steam-run           # Run binaries in the Steam FHS environment
    vulkan-tools
    vulkan-loader

  ];

  # ── 32-Bit Support ────────────────────────────────────────────
  # Essential for older games and many Wine/Proton applications.
  hardware.graphics.enable32Bit = true;

  # ── GameMode Configuration ────────────────────────────────────
  # Optimizes CPU governor, process nice, and GPU power level.
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 15; # High priority for games
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermode_offset = 1; # Set NVIDIA to "Prefer Maximum Performance"
      };
      custom = {
        start = "notify-send 'GameMode' 'Turbo Active - GPU Max Performance'";
        stop = "notify-send 'GameMode' 'Turbo Disabled - Resetting'";
      };
    };
  };


  # ── Steam & Protocol Support ─────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true; # LAN game transfers
    gamescopeSession.enable = true; # Micro-compositor for better frame pacing
    extraCompatPackages = [ pkgs.proton-ge-bin ];

  };

  # ── Steam/Proton Stability Environment Variables ──────────────
  # These are set session-wide so Steam, Lutris, Heroic all benefit.
  environment.sessionVariables = {
    # Force Steam to use system libs over its bundled (broken) ones
    STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "1";
    # Prevent Steam from fighting Plasma for GPU resources
    SDL_VIDEODRIVER = "x11";
    # Force-enable DXVK async shader compilation → prevents stutter-crashes
    DXVK_ASYNC = "1";
    # Enable Proton ESync + FSync for lower-latency IPC (prevents deadlock crashes)
    PROTON_NO_ESYNC = "0";
    PROTON_NO_FSYNC = "0";
    # Disable Proton's verbose logging (log spam can cause I/O freezes)
    PROTON_LOG = "0";
    DXVK_LOG_LEVEL = "none";
  };

  # ── Gamescope ─────────────────────────────────────────────────
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # ── Heavy Repack & Memory Fixes ───────────────────────────────
  # Large games (especially repacks) need high memory mapping limits
  # and unlimited stack size to prevent crashes during decompression.
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Prevents out-of-memory errors in Wine
    "fs.file-max" = 524288;          # Higher open file limit
  };
  security.pam.loginLimits = [
    { domain = "*"; type = "hard"; item = "stack"; value = "unlimited"; }
    { domain = "*"; type = "soft"; item = "stack"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
    { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
  ];
}
