{ pkgs, lib, ... }:
{
  programs.plasma = {
    enable = true;
    overrideConfig = false;

    # ── Declarative KDE Plasma Configuration ──────────────────────
    # Powered by plasma-manager. This ensures a consistent, high-performance
    # desktop experience across all installations.

    # ── KWin (Window Manager) ──────────────────────────────────
    kwin = {
      effects = {
        wobblyWindows.enable = false;
        blur.enable = false; # Disabled for maximum X11 performance
      };
    };

    # ── Workspace & Splash ──────────────────────────────────────
    # Disable splash screen for faster "perceived" boot speed.
    workspace = {
      splashScreen.theme = "None";
      splashScreen.engine = "none";
      # theme = "breeze-dark"; # Removed as per new config
    };

    # ── Power & Session ─────────────────────────────────────────
    # Start with an empty session to prevent old processes from slowing down login.
    # TODO: Verify correct Plasma 6 option for this in plasma-manager
    # session.restoreSession = "emptySession";

    # ── Styling & Performance Tokens ───────────────────────────
    # Maps to kdeglobals: Animation Speed (0.2 = Ultra-fast)
    configFile."kdeglobals"."KDE"."AnimationDurationFactor" = 0.2;

    # ── Fonts ───────────────────────────────────────────────────
    # Premium typography settings for high-density displays.
    fonts = {
      general = {
        family = "Inter";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
      small = {
        family = "Inter";
        pointSize = 8;
      };
      toolbar = {
        family = "Inter";
        pointSize = 10;
      };
      menu = {
        family = "Inter";
        pointSize = 10;
      };
      windowTitle = {
        family = "Inter";
        pointSize = 10;
      };
    };
  };
}
