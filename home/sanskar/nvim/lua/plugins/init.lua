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

  -- AI Copilot / opencode support
  {
    "Kaiser-Yang/opencode.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {},               -- Call setup() automatically
    cmd = { "OpenCode" },    -- Lazy load on command
  },
}
