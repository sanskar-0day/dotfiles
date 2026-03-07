{ config, pkgs, ... }:

let
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

  # ── Sekiro Plymouth Theme (matches GRUB) ────────────────────
  sekiroPlymouthTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-sekiro";
    version = "1.0";

    src = sekiroGrubTheme;

    nativeBuildInputs = [ pkgs.imagemagick ];

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/sekiro

      # Use the Sekiro 1920x1080 background from the GRUB theme
      cp "$src/sekiro_1920x1080.png" "$out/share/plymouth/themes/sekiro/background.png"

      # Generate spinner frames (a subtle pulsing dot)
      for i in $(seq 0 23); do
        # Calculate opacity: cycles smoothly 0→1→0 over 24 frames
        OPACITY=$(echo "scale=2; s($i * 3.14159 / 12) * 0.6 + 0.4" | ${pkgs.bc}/bin/bc -l)

        convert -size 48x48 xc:none \
          -fill "rgba(177,64,70,$OPACITY)" \
          -draw "circle 24,24 24,4" \
          "$out/share/plymouth/themes/sekiro/spinner-$i.png"
      done

      # Plymouth theme descriptor
      cat > "$out/share/plymouth/themes/sekiro/sekiro.plymouth" <<EOF
      [Plymouth Theme]
      Name=Sekiro
      Description=Sekiro-themed boot splash with loading spinner
      ModuleName=script

      [script]
      ImageDir=$out/share/plymouth/themes/sekiro
      ScriptFile=$out/share/plymouth/themes/sekiro/sekiro.script
      EOF

      # Plymouth script – background + animated spinner
      cat > "$out/share/plymouth/themes/sekiro/sekiro.script" <<'SCRIPT'
      // Background
      wallpaper = Image("background.png");
      screen_w = Window.GetWidth();
      screen_h = Window.GetHeight();
      resized = wallpaper.Scale(screen_w, screen_h);
      bg_sprite = Sprite(resized);
      bg_sprite.SetX(0);
      bg_sprite.SetY(0);
      bg_sprite.SetZ(-100);

      // Spinner animation (24 frames, pulsing dot)
      spinner_frames = [];
      for (i = 0; i < 24; i++) {
        spinner_frames[i] = Image("spinner-" + i + ".png");
      }

      spinner_sprite = Sprite();
      spinner_sprite.SetX(screen_w / 2 - 24);
      spinner_sprite.SetY(screen_h * 0.85);
      spinner_sprite.SetZ(100);

      frame = 0;
      fun refresh_callback() {
        spinner_sprite.SetImage(spinner_frames[Math.Int(frame)]);
        frame = (frame + 0.5) % 24;
      }
      Plymouth.SetRefreshFunction(refresh_callback);
      SCRIPT
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

      # Show the menu so you can admire the Sekiro art
      timeoutStyle = "menu";

      # Limit generations shown in menu
      configurationLimit = 10;
    };

    # 5 seconds to pick a generation — enough to see the theme
    timeout = 5;
  };

  # ── Plymouth Boot Splash ─────────────────────────────────────
  # Using adi1090x's premium animated themes (80+ options)
  # Change theme name to try others: rings, hexagon_dots, deus_ex, etc.
  boot.plymouth = {
    enable = true;
    theme = "lone";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "lone" ]; })
    ];
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
