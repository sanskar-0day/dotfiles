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
    historyLimit = 50000;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      dracula
      resurrect
      continuum
      yank
      vim-tmux-navigator
      pain-control
      sensible
    ];
    extraConfig = ''
      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

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

      # Vi copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

      # Easy config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Swap windows
      bind -r < swap-window -t -1\; select-window -t -1
      bind -r > swap-window -t +1\; select-window -t +1

      # Kill pane without confirmation
      bind x kill-pane

      # Stay in rename mode
      bind , command-prompt "rename-window '%%'"

      # Quick window selection
      bind-key -n C-S-Left previous-window
      bind-key -n C-S-Right next-window
    '';
  };

  # ── atuin (shell history search) ────────────────────────────────
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "compact";
      inline_height = 20;
      search_mode = "fuzzy";
      filter_mode = "global";
      history_filter = [
        "^ls"
        "^cd"
        "^cat"
        "^echo"
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
      activeBorderColor = [
        "#50fa7b"
        "bold"
      ];
      inactiveBorderColor = [ "#6272a4" ];
      selectedLineBgColor = [ "#44475a" ];
    };
  };

  # ── nix-index (fuzzy nix package search) ─────────────────────
  # Note: nix-index is configured via nix-index-database flake module

  # ── topgrade (upgrade everything) ─────────────────────────────
  programs.topgrade = {
    enable = true;
    settings = {
      disable = [
        "node_modules" # npm global upgrades
        "pip3" # pip upgrades
      ];
      git_repos = [
        "~/dotfiles"
        "~/.local/share/src"
      ];
      commands = {
        "NixOS" = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
        "Home Manager" = "home-manager switch --flake ~/dotfiles#sanskar";
      };
    };
  };

  # ── CLI packages ──────────────────────────────────────────────
  home.packages = with pkgs; [
    # Core search/file tools
    ripgrep
    fd
    eza

    # Modern replacements
    sd # better sed
    hexyl # better hexdump
    duf # better df (disk free)
    dust # better du (disk usage)
    dua # interactive disk usage tool
    procs # better ps (processes)
    dogdns # better dig (DNS lookup)
    trash-cli # safer rm (moves to trash)
    tealdeer # tldr – simplified man pages
    vivid # LS_COLORS generator
    hyperfine # benchmarking tool
    tokei # code statistics
    entr # run commands on file change
    rsync # file sync
    httpie # modern curl replacement

    # Nix tools
    any-nix-shell # use zsh for nix-shell
    nvd # NixOS version diff (compare generations)
    nh # yet another nix cli helper
    nix-output-monitor # nom - pretty output for nix builds
    nix-fast-build # fast concurrent nix builds
    nurl # generate nix fetchurl/fetchFromGitHub
    comma # run programs without installing (npx-like)
    devenv # reproducible developer environments

    # Git extras
    delta # better diffs (also configured in git.nix)
    git-extras # extra git commands

    # Docker TUI
    lazydocker # docker TUI (like lazygit for docker)
    dive # explore docker image layers

    # System monitoring
    bandwhich # network bandwidth monitor
    bottom # another system monitor (alternative to btop)

    # Utilities
    glow # render markdown in terminal
    topgrade # upgrade everything at once
    curlie # curl with httpie-like output
    mosh # mobile shell (roaming SSH)
    jq # JSON processor
    yq # YAML processor
    unzip
    wl-clipboard
    rlwrap
    bluez
    bluez-tools
    curl
    wget
    lsof # list open files
    tree # directory tree view
    which # locate a command
  ];
}
