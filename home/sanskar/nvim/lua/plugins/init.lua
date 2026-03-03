-- Custom plugin overrides / additions
-- LazyVim already includes: treesitter, telescope, lsp, cmp, neo-tree, etc.
return {
  -- Dracula theme
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "dracula" },
  },

  -- Nix language support
  { "LnL7/vim-nix", ft = "nix" },
}
