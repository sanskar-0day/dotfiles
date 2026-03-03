{ pkgs, ... }:
{
  # ── bat (better cat) ──────────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "Dracula";
  };

  # ── fzf (fuzzy finder) ────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # ── zoxide (better cd) ────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── direnv (per-directory envs) ────────────────────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # ── btop (system monitor) ─────────────────────────────────────
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      vim_keys = true;
      update_ms = 1000;
    };
  };

  # ── tmux ──────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    extraConfig = ''
      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Navigate panes with vim keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Status bar
      set -g status-style "bg=#282a36,fg=#f8f8f2"
      set -g status-left "#[bold] #S "
      set -g status-right "%H:%M "
    '';
  };

  # ── atuin (shell history search) ────────────────────────────────
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      style = "compact";
      inline_height = 20;
      search_mode = "fuzzy";
      filter_mode = "global";
      history_filter = [
        "^ls" "^cd" "^cat" "^echo"
      ];
    };
  };

  # ── yazi (terminal file manager) ───────────────────────────────
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── lazygit (git TUI) ─────────────────────────────────────────
  programs.lazygit = {
    enable = true;
    settings.gui.theme = {
      lightTheme = false;
      activeBorderColor = [ "#50fa7b" "bold" ];
      inactiveBorderColor = [ "#6272a4" ];
      selectedLineBgColor = [ "#44475a" ];
    };
  };

  # ── CLI packages ──────────────────────────────────────────────
  home.packages = with pkgs; [
    ripgrep fd eza
    unzip wl-clipboard rlwrap
    bluez bluez-tools
    delta
  ];
}
