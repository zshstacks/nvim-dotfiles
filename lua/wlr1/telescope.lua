-- lua/wlr4/telescope.lua
local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    hidden = true,
    no_ignore = false,
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-c>"] = actions.close,
        ["<CR>"] = actions.select_default,
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["q"] = actions.close,
      },
    },
  },
  extensions = {
    file_browser = {},
    zoxide = {},
  },
})

telescope.load_extension("zoxide")

vim.keymap.set("n", "<leader>jk", function()
  builtin.find_files({
    find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
  })
end, { desc = "🔍 Find Files (rg, hidden)" })

vim.keymap.set("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", { desc = "📂 File Browser" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "🔍 Live Grep" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "🔍 Diagnostics" })
vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "🔍 LSP Document Symbols" })
vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, { desc = "🔍 LSP Workspace Symbols" })
vim.keymap.set("n", "<leader>fz", "<cmd>Telescope zoxide list<CR>", { desc = "🔍 Zoxide List" })
vim.keymap.set("n", "<leader>fv", builtin.help_tags, { desc = "🔍 Help Tags" })
