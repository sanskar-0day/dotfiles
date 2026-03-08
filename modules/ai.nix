{ config, pkgs, unstable, ... }:
{
  # ── Local AI Infrastructure (LM Studio) ───────────────────────

  environment.systemPackages = with pkgs; [
    unstable.lmstudio
  ];
}
