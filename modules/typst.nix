{ pkgs, ... }:
{
  # ── Typst Ecosystem ────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    typst
    typst-live
    typstwriter
    tinymist
    prettypst
    typship
    typesetter
    typewriter
  ];

  fonts.packages = with pkgs; [
    libertinus
  ];
}
