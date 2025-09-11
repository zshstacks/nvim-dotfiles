local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- leader is spacebar
--jump to the last character and write(Shift + a)
--undo(u)
--redo(ctrl + r)
--copy the line(yy)
--paste(p) \normal mode
--delete a word backwards(db)
--delete a character backwards (x)
--delete entire line in normal mode(dd)
--jump to the end of the file(G)
--jump to exact line(<number>G \ 22G)
--jump to the top of the file(gg)
--jumps to the next thing(w)
--jumps to the prev thing(b)
--comment highlighted(gc)
--jumps forward to the end of the current word(e)
--adds a new line and insert mode(o)
--jump to the next paragraph (shift + } or {)
--highlight line to line(v - character highlight, V-line highlight, ctrl + V - block highlight)
--find a word(/ then enter a word, n next N prev)
--find a word which is on your cursor (*)
--to replace all words to another word (:%s/old/new/g)
-- show hidden files in explorer(Mh)
-- telescope file explorer (<leader>fb)
-- find files (<leader>jk)
--  open yazi in current file(<leader>x) q to quit yazi
--  new tab(<leader>Tab-Tab)

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

keymap.set("n", "<leader><leader>", function()
  local fname = vim.fn.expand("%:p")
  if fname == "" then
    -- ja nav atvērta neviens fails, atver jaunu tukšu tab
    vim.cmd("tabnew")
    return
  end
  -- atver failu jaunā tab un iestata tab-local cwd uz tā direktoriju
  vim.cmd("tab split " .. vim.fn.fnameescape(fname))
  local dir = vim.fn.fnamemodify(fname, ":h")
  vim.cmd("tcd " .. vim.fn.fnameescape(dir))
end, opts)

keymap.set("n", "<leader><tab><tab>", ":tab split %<CR>:tcd %:p:h<CR>", opts)

--Split window (ss split bottom, sv split horizont, sx close window, se correct all wind size )
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
keymap.set("n", "sx", ":close<CR>")
keymap.set("n", "se", "<C-w>=")

--Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

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
    max_width = 153, --  window width restriction
  })
end, opts)

-- go to the next diagnocstic
keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

--  go to prev diagnoctic
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

-- quickfix window
keymap.set("n", "<leader>q", function()
  vim.diagnostic.setloclist({ open = true })
end, opts)

---==================================================================================
local function get_project_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start_path = ""
  if bufname ~= "" then
    start_path = vim.fn.fnamemodify(bufname, ":p:h")
  else
    start_path = vim.loop.cwd()
  end

  -- 1) LSP root
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    local root = client.config and client.config.root_dir
    if root and root ~= "" and vim.fn.isdirectory(root) == 1 then
      return root
    end
  end

  -- 2) Git root
  local ok, git_out = pcall(vim.fn.systemlist, 'git -C "' .. start_path .. '" rev-parse --show-toplevel')
  if ok and type(git_out) == "table" and git_out[1] and git_out[1] ~= "" then
    local candidate = git_out[1]
    if vim.fn.isdirectory(candidate) == 1 then
      return candidate
    end
  end

  -- 3) Marker failu meklēšana
  local markers = { ".git", "go.mod", "Cargo.toml", "package.json", "pyproject.toml" }
  local path = start_path
  while path and path ~= "" do
    for _, m in ipairs(markers) do
      if vim.fn.glob(path .. "/" .. m) ~= "" then
        return path
      end
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      break
    end
    path = parent
  end

  -- 4) Fallback uz pašreizējo faila direktoriju
  return start_path
end

-- Palīdzfunkcija drošai escape'ot ceļu komandu vidē
local function fnameescape(path)
  return vim.fn.fnameescape(path)
end

-- Toggle floating terminal that opens in project root
local float_win = nil
local float_buf = nil
local function toggle_project_float_term()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
    float_buf = nil
    return
  end

  local root = get_project_root()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
  }

  float_win = vim.api.nvim_open_win(buf, true, win_opts)
  float_buf = buf
  -- atver shell termināli ar cwd = project root
  vim.fn.termopen(vim.o.shell, { cwd = root })
  vim.cmd("startinsert")
end

-- Open terminal in horizontal split in project root
local function open_project_hsplit_term()
  local root = get_project_root()
  vim.cmd("split")
  vim.cmd("lcd " .. fnameescape(root))
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- Open terminal in vertical split in project root
local function open_project_vsplit_term()
  local root = get_project_root()
  vim.cmd("vsplit")
  vim.cmd("lcd " .. fnameescape(root))
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- Open terminal in new tab in project root
local function open_project_tab_term()
  local root = get_project_root()
  vim.cmd("tabnew")
  vim.cmd("lcd " .. fnameescape(root))
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- Eksportējam, ja vajag piekļuvi no cmd līnijas
_G.toggle_project_float_term = toggle_project_float_term
_G.open_project_hsplit_term = open_project_hsplit_term
_G.open_project_vsplit_term = open_project_vsplit_term
_G.open_project_tab_term = open_project_tab_term

-- Mappings (izmanto tavas opts/ keymap)
keymap.set("n", "<leader>t", toggle_project_float_term, opts) -- toggle floating terminal in project root
keymap.set("n", "<leader>ht", open_project_hsplit_term, opts) -- horizontal split terminal in project root
keymap.set("n", "<leader>vt", open_project_vsplit_term, opts) -- vertical split terminal in project root
keymap.set("n", "<leader>rt", open_project_tab_term, opts) -- terminal in new tab in project root

-- Terminal mode navigācija & iziešana
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)
