{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # LazyVim dependencies
      gcc gnumake
      ripgrep fd
      # LSP servers
      lua-language-server
      nil                  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      pyright
    ];
  };

  # Symlink LazyVim config files into ~/.config/nvim
  xdg.configFile = {
    "nvim/init.lua".source             = ./nvim/init.lua;
    "nvim/lua/config/lazy.lua".source  = ./nvim/lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./nvim/lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./nvim/lua/config/keymaps.lua;
    "nvim/lua/config/autocmds.lua".source = ./nvim/lua/config/autocmds.lua;
    "nvim/lua/plugins/init.lua".source = ./nvim/lua/plugins/init.lua;
  };
}
