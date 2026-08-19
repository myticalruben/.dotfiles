return {
	{
		"mrcjkb/rustaceanvim",
		opts = {
			server = {
				cmd = function()
					-- resuelve la ruta al rust-analyzer del toolchain stable dinámicamente
					local ra_path = vim.fn.trim(vim.fn.system("rustup which --toolchain stable rust-analyzer"))
					return { ra_path }
				end,
			},
		},
	},
}
