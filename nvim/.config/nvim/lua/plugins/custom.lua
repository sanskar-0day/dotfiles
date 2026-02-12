-- Custom plugins (loaded after LazyVim's defaults)
-- Add any additional plugins here

return {
	-- Transparent background support
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
		opts = {
			extra_groups = {
				"NormalFloat",
				"NvimTreeNormal",
			},
		},
	},
}
