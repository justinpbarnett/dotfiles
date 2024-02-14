-- Abstraction layer for most LSPs
return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.completion.spell,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.formatting.csharpier,
				null_ls.builtins.diagnostics.eslint_d.with({ -- js/ts linter
					condition = function(utils)
						return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" }) -- only enable if root has .eslintrc.js or .eslintrc.cjs
					end,
				}),
				null_ls.builtins.code_actions.refactoring,
				null_ls.builtins.code_actions.shellcheck,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.gofumpt,
			},
		})
	end,
}
