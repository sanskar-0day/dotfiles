{ config, pkgs, pkgs-unstable, ... }:
{
  imports = [
    ./shell.nix   # Zsh + Starship
    ./git.nix     # Git + Delta
    ./tools.nix   # bat, fzf, zoxide, direnv, btop, tmux
    ./nvim.nix    # Neovim (LazyVim)
    ./dev.nix     # IDEs, Languages
  ];

  # User-specific packages
  home.packages = with pkgs; [
    firefox
    kdePackages.spectacle
    kdePackages.polkit-kde-agent-1
    kdePackages.plasma-nm
    nvtopPackages.full
    mesa-demos
    winboat
    freerdp
    pkgs-unstable.antigravity
    fastfetch

    # Nerd Fonts (required for icons in starship, eza, lazyvim)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Enable fontconfig for Home Manager fonts
  fonts.fontconfig.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Home Manager state version
  home.stateVersion = "25.11";
}