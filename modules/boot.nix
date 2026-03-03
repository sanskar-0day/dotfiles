{ config, pkgs, ... }:

let
  # ── Custom Plymouth Theme (boot splash after bootloader) ─────
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

      # Also prepare the black hole as an alternate
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

  # ── Sekiro GRUB Theme ───────────────────────────────────────
  sekiroGrubTheme = pkgs.stdenv.mkDerivation {
    pname = "sekiro-grub-theme";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "AbijithBalaji";
      repo = "sekiro_grub_theme";
      rev = "main";
      sha256 = "01zrryxvffg2gp1mgz3c441cb70bkw3yc1pbflpj8miypn6h6z5r";
    };

    installPhase = ''
      mkdir -p $out
      cp -r Sekiro/* $out/
    '';
  };
in
{
  # ── GRUB Bootloader ────────────────────────────────────────────
  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";        # UEFI mode (no MBR device)
      useOSProber = false;     # Set to true if dual-booting

      # Sekiro theme
      theme = sekiroGrubTheme;
      splashImage = null;      # Let the theme handle the background

      # 1-second timeout — "Hesitation is defeat"
      timeoutStyle = "menu";
    };

    timeout = 1;
  };

  # ── Plymouth Boot Splash (after GRUB hands off) ──────────────
  boot.plymouth = {
    enable = true;
    theme = "nixos-custom";
    themePackages = [ customPlymouthTheme ];
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

  # ── Faster Shutdown ───────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
