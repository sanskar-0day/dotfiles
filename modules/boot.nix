{ config, pkgs, ... }:

let
  # Custom Plymouth theme built from your wallpapers
  customPlymouthTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-nixos-custom";
    version = "1.0";

    src = ../images;

    nativeBuildInputs = [ pkgs.imagemagick ];

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/nixos-custom

      # Convert and resize the romantic night sky to 1080p PNG
      convert "$src/romantic-night-sky-3840x2160-25549.jpg" \
        -resize 1920x1080! \
        -quality 95 \
        "$out/share/plymouth/themes/nixos-custom/background.png"

      # Also prepare the black hole as an alternate (swap in .plymouth to use)
      convert "$src/gargantua-black-3840x2160-9621.jpg" \
        -resize 1920x1080! \
        -quality 95 \
        "$out/share/plymouth/themes/nixos-custom/background-blackhole.png"

      # Plymouth theme descriptor
      cat > "$out/share/plymouth/themes/nixos-custom/nixos-custom.plymouth" <<EOF
      [Plymouth Theme]
      Name=NixOS Custom
      Description=Custom boot splash with wallpaper
      ModuleName=script

      [script]
      ImageDir=$out/share/plymouth/themes/nixos-custom
      ScriptFile=$out/share/plymouth/themes/nixos-custom/nixos-custom.script
      EOF

      # Plymouth script – display the background image centered
      cat > "$out/share/plymouth/themes/nixos-custom/nixos-custom.script" <<'SCRIPT'
      wallpaper = Image("background.png");
      screen_width = Window.GetWidth();
      screen_height = Window.GetHeight();
      resized = wallpaper.Scale(screen_width, screen_height);
      sprite = Sprite(resized);
      sprite.SetX(0);
      sprite.SetY(0);
      sprite.SetZ(-100);

      fun refresh_callback() {
        // Nothing extra needed – static image
      }
      Plymouth.SetRefreshFunction(refresh_callback);
      SCRIPT
    '';
  };
in
{
  # ── Plymouth Boot Splash ──────────────────────────────────────
  boot.plymouth = {
    enable = false; # Set to false due to black screen issues
    # theme = "nixos-custom";
    # themePackages = [ customPlymouthTheme ];
  };

  # ── Silent & Fast Boot ────────────────────────────────────────
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "boot.shell_on_fail"
  ];

  boot.loader.timeout = 1;  # 1 second to pick a generation, then auto-boot

  # ── Faster Shutdown ───────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
