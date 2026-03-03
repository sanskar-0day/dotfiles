{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # ── LazyVim core deps ──────────────────────────────────
      gcc gnumake
      ripgrep fd
      tree-sitter            # Treesitter CLI (auto grammar install)

      # ── LSP Servers ────────────────────────────────────────
      lua-language-server    # Lua
      nil                    # Nix
      pyright                # Python (type checking)
      ruff                   # Python (linting + formatting LSP)
      zls                    # Zig
      nimlangserver          # Nim
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON/ESLint
      taplo                  # TOML
      yaml-language-server   # YAML
      marksman               # Markdown

      # ── Formatters (used by conform.nvim) ──────────────────
      black                  # Python
      stylua                 # Lua
      nixfmt-rfc-style       # Nix
      nodePackages.prettier  # JS/TS/JSON/CSS/HTML/Markdown
      shfmt                  # Shell

      # ── Linters (used by nvim-lint) ────────────────────────
      shellcheck             # Shell
      
      # ── Debug Adapters (used by nvim-dap) ──────────────────
      python313Packages.debugpy  # Python DAP
    ];
  };

  # Symlink LazyVim config files into ~/.config/nvim
  xdg.configFile = {
    "nvim/init.lua".source              = ./nvim/init.lua;
    "nvim/lua/config/lazy.lua".source   = ./nvim/lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./nvim/lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./nvim/lua/config/keymaps.lua;
    "nvim/lua/config/autocmds.lua".source = ./nvim/lua/config/autocmds.lua;
    "nvim/lua/plugins/init.lua".source  = ./nvim/lua/plugins/init.lua;
    "nvim/lua/plugins/lang.lua".source  = ./nvim/lua/plugins/lang.lua;
  };
}
