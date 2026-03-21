{ pkgs, lib, ... }:
{
  programs.plasma = {
    enable = true;
    overrideConfig = false; # Keep false initially to avoid wiping GUI changes

    kwin = {
      effects = {
        wobblyWindows.enable = false;
        blur.enable = false;
      };
      compositingType = "OpenGL";
      latencyPolicy = "Low";
    };

    # Splash screen off (maps to ksplashrc)
    workspace = {
      splashScreen.theme = "None";
      theme = "breeze-dark";
    };

    # Empty session on login (maps to ksmserverrc)
    startup.startupFeedback = "none";

    fonts = {
      general = {
        family = "Inter";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    };

    # AnimationDurationFactor (maps to kdeglobals)
    animations.speed = 5; # plasma-manager scale: 1=slow, 5=normal, 10=instant
  };
}
