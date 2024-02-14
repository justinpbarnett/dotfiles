-- Sets up the installed LSPs from Mason and uses them in code.
-- Allows for showing diagnostics, code actions and go-to-definition functions.
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"Hoffs/omnisharp-extended-lsp.nvim",
	},
	lazy = false,
	config = function()
		require("cmp").setup({
			sources = {
				{ name = "nvim_lsp" },
			},
		})
		-- Setup language servers.
		local lspconfig = require("lspconfig")
		local capabilities = vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), {
			workspace = {
				didChangeWatchedFiles = {
					dynamicRegistration = true,
				},
			},
		})
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
		})
		lspconfig.html.setup({
			capabilities = capabilities,
		})
		lspconfig.cssls.setup({
			capabilities = capabilities,
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})
		lspconfig.tsserver.setup({
			capabilities = capabilities,
		})
		lspconfig.csharp_ls.setup({
			capabilities = capabilities,
		})
		lspconfig.gopls.setup({
			capabilities = capabilities,
		})
		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
		})
		-- local omnisharp_bin = "C:/Users/justi/AppData/Local/nvim-data/mason/bin/omnisharp.cmd"
		-- lspconfig.omnisharp.setup({
		-- 	capabilities = capabilities,
		-- 	handlers = {
		-- 		["textDocument/definition"] = require("omnisharp_extended").handler,
		-- 	},
		-- 	cmd = {
		-- 		omnisharp_bin,
		-- 		"--assembly-loader=strict",
		-- 		"--languageserver",
		-- 		"--hostPID",
		-- 		tostring(vim.fn.getpid()),
		-- 	},

		-- 	-- Enables support for reading code style, naming convention and analyzer
		-- 	-- settings from .editorconfig.
		-- 	enable_editorconfig_support = true,

		-- 	-- If true, MSBuild project system will only load projects for files that
		-- 	-- were opened in the editor. This setting is useful for big C# codebases
		-- 	-- and allows for faster initialization of code navigation features only
		-- 	-- for projects that are relevant to code that is being edited. With this
		-- 	-- setting enabled OmniSharp may load fewer projects and may thus display
		-- 	-- incomplete reference lists for symbols.
		-- 	enable_ms_build_load_projects_on_demand = false,

		-- 	-- Enables support for roslyn analyzers, code fixes and rulesets.
		-- 	enable_roslyn_analyzers = false,

		-- 	-- Specifies whether 'using' directives should be grouped and sorted during
		-- 	-- document formatting.
		-- 	organize_imports_on_format = true,

		-- 	-- Enables support for showing unimported types and unimported extension
		-- 	-- methods in completion lists. When committed, the appropriate using
		-- 	-- directive will be added at the top of the current file. This option can
		-- 	-- have a negative impact on initial completion responsiveness,
		-- 	-- particularly for the first few completion sessions after opening a
		-- 	-- solution.
		-- 	enable_import_completion = true,

		-- 	-- Specifies whether to include preview versions of the .NET SDK when
		-- 	-- determining which version to use for project loading.
		-- 	sdk_include_prereleases = true,

		-- 	-- Only run analyzers against open files when 'enableRoslynAnalyzers' is
		-- 	-- true
		-- 	analyze_open_documents_only = false,
		-- })
		lspconfig.pyright.setup({
			capabilities = capabilities,
		})
		--lspconfig.golangci_lint_ls.setup({
		--    capabilities = capabilities,
		--})
		-- Global mappings.
		-- See `:help vim.diagnostic.*` for documentation on any of the below functions
		vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
		vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)
		-- Use LspAttach autocommand to only map the following keys
		-- after the language server attaches to the current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<space>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
				vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<space>fo", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end,
		})
	end,
}
