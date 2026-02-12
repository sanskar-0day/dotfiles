-- LazyVim starter config
-- This bootstraps lazy.nvim and loads the LazyVim distribution

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with LazyVim
require("lazy").setup({
	spec = {
		-- Import LazyVim and its plugins
		{
			"LazyVim/LazyVim",
			import = "lazyvim.plugins",
			opts = {
				colorscheme = "catppuccin-mocha",
			},
		},

		-- Extra language packs
		{ import = "lazyvim.plugins.extras.lang.python" },
		{ import = "lazyvim.plugins.extras.lang.typescript" },
		{ import = "lazyvim.plugins.extras.lang.rust" },
		{ import = "lazyvim.plugins.extras.lang.go" },
		{ import = "lazyvim.plugins.extras.lang.json" },
		{ import = "lazyvim.plugins.extras.lang.yaml" },
		{ import = "lazyvim.plugins.extras.lang.markdown" },
		{ import = "lazyvim.plugins.extras.lang.docker" },

		-- Extra features
		{ import = "lazyvim.plugins.extras.editor.mini-files" },

		-- Catppuccin colorscheme
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			opts = {
				flavour = "mocha",
				transparent_background = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					treesitter = true,
					notify = true,
					mini = { enabled = true },
					telescope = { enabled = true },
					which_key = true,
					mason = true,
					native_lsp = {
						enabled = true,
					},
				},
			},
		},

		-- Any additional plugins
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false,
	},
	checker = { enabled = true },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
