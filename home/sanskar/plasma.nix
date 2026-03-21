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
      # Note: renderingBackend might not be a valid option in all plasma-manager versions, 
      # but we'll stick to the user's request.
    };

    fonts = {
      general = { family = "Inter"; pointSize = 10; };
      fixedWidth = { family = "JetBrainsMono Nerd Font"; pointSize = 10; };
    };

    workspace.theme = "breeze-dark";
  };
}
