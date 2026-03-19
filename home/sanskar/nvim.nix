{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # LazyVim core
      gcc
      gnumake
      ripgrep
      fd
      tree-sitter

      # AI plugin deps (avante.nvim, copilot, codecompanion)
      pkg-config
      cargo
      nodejs_20
      lua5_1
      luajitPackages.luarocks-nix
      sqlite
      curl
      openssl
      unzip

      # LSP servers
      lua-language-server # Lua
      nil # Nix
      pyright # Python type checking
      ruff # Python linting + formatting
      zls # Zig
      nimlangserver # Nim
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
      taplo # TOML
      yaml-language-server # YAML
      marksman # Markdown
      sbcl # Common Lisp

      # Formatters (used by conform.nvim)
      black # Python formatter
      stylua # Lua formatter
      nixfmt-rfc-style # Nix formatter
      typstyle # Typst formatter
      nodePackages.prettier # JS/TS/JSON/CSS/HTML formatter
      shfmt # Shell formatter
      shellcheck # Shell linter

      # Debug adapters
      python313Packages.debugpy # Python debug adapter

      # Git
      lazygit # Git TUI
    ];
  };

  # Symlink LazyVim config into ~/.config/nvim
  xdg.configFile = {
    "nvim/init.lua".source = ./nvim/init.lua;
    "nvim/lua/config/lazy.lua".source = ./nvim/lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./nvim/lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./nvim/lua/config/keymaps.lua;
    "nvim/lua/config/autocmds.lua".source = ./nvim/lua/config/autocmds.lua;
    "nvim/lua/plugins/init.lua".source = ./nvim/lua/plugins/init.lua;
    "nvim/lua/plugins/lang.lua".source = ./nvim/lua/plugins/lang.lua;
  };
}
