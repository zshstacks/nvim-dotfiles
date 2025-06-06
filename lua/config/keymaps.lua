local keymap = vim.keymap
local opts = { noremap = true, silent = true }

--undo(u)
--redo(ctrl + r)
--delete a word backwards(db)
--delete a character backwards (x)
--highlight line to line(v - character highlight, V-line highlight, ctrl + V - block highlight)
--find a word(/ then enter a word, n next N prev)
--find a word which is on your cursor (*)
--to replace all words to another word (:%s/old/new/g)
-- show hidden files in explorer(Mh)

--highlight and delete all
keymap.set("n", "da", "ggVGd", { desc = "Highlight and delete all" })

--highlight and copy all
keymap.set("n", "ya", "ggVGy", { desc = "Highlight and copy all" })

--Increment/decrement  normal mod press + or -
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "C-x")

-- Delete a word backwards (v then b then d)
keymap.set("n", "dw", "vb_d")

--Select all (gg first file line, shift-v line-visual, shitf-g all file highlight)
keymap.set("n", "<C-a>", "gg<S-v>G")

--Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

--New tab (te - enter new tab, Tab prev and nex tab)
keymap.set("n", "te", ":tabedit", opts)
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
keymap.set("n", "tf", function()
  local file = vim.fn.input("File path: ")
  if file ~= "" then
    vim.cmd("tabedit " .. file)
  end
end, opts)

--Split window (ss split bottom, sv split horizont, sx close window, se correct all wind size )
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
keymap.set("n", "sx", ":close<CR>")
keymap.set("n", "se", "<C-w>=")

--Move window
keymap.set("n", "C-h", "<C-w>h")
keymap.set("n", "C-k", "<C-w>k")
keymap.set("n", "C-j", "<C-w>j")
keymap.set("n", "C-l", "<C-w>l")

--Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "C-w>+")
keymap.set("n", "<C-w><down>", "C-w>-")

keymap.set("n", "<leader>z", function()
  vim.diagnostic.open_float(nil, {
    scope = "cursor", -- show here
    border = "rounded", -- rounded borders
    source = "always", -- show from which lsp this is
    max_width = 150, --  window width restriction
  })
end, opts)

-- go to the next diagnostic
keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

--  go to prev diagnoctic
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

-- quickfix window
keymap.set("n", "<leader>q", function()
  vim.diagnostic.setloclist({ open = true })
end, opts)
