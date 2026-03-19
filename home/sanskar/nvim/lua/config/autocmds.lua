-- ==========================================
-- Custom Autocmds
-- ==========================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on yank ────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- ── Remove trailing whitespace on save ───────────────────
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- ── Return to last edit position ─────────────────────────
autocmd("BufReadPost", {
  group = augroup("LastPosition", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lines = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Close some filetypes with <q> ────────────────────────
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "man", "notify", "lspinfo", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ── Auto-resize splits when terminal is resized ──────────
autocmd("VimResized", {
  group = augroup("AutoResize", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ── Set filetype for special files ───────────────────────
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("SpecialFiletypes", { clear = true }),
  pattern = { "*.typ" },
  callback = function()
    vim.bo.filetype = "typst"
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("NixFlake", { clear = true }),
  pattern = { "flake.lock" },
  callback = function()
    vim.bo.filetype = "json"
  end,
})

-- ── Autosave on focus lost ───────────────────────────────
autocmd("FocusLost", {
  group = augroup("AutoSave", { clear = true }),
  callback = function()
    if vim.bo.modified and not vim.bo.readonly then
      vim.cmd("silent! write")
    end
  end,
})

-- ── Clear search on insert enter ─────────────────────────
autocmd("InsertEnter", {
  group = augroup("ClearSearch", { clear = true }),
  callback = function()
    vim.opt.hlsearch = false
  end,
})

-- ── Highlight color column only in active window ─────────
autocmd({ "WinEnter", "BufEnter" }, {
  group = augroup("ColorColumnActive", { clear = true }),
  callback = function()
    vim.opt_local.colorcolumn = "80,120"
  end,
})

autocmd({ "WinLeave", "BufLeave" }, {
  group = augroup("ColorColumnInactive", { clear = true }),
  callback = function()
    vim.opt_local.colorcolumn = ""
  end,
})

-- ── Auto-create directories on save ──────────────────────
autocmd("BufWritePre", {
  group = augroup("AutoCreateDir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local dir = vim.fn.fnamemodify(event.match, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- ── Disable swap files for certain filetypes ─────────────
autocmd("SwapExists", {
  group = augroup("NoSwapForSpecial", { clear = true }),
  pattern = { "*.txt", "*.md", "*.typ" },
  callback = function()
    vim.v.swapchoice = "e"
  end,
})

-- ── Auto-resize nvim-tree when window is resized ─────────
autocmd("VimResized", {
  group = augroup("NvimTreeResize", { clear = true }),
  callback = function()
    local nvimtree = require("nvim-tree")
    nvimtree.resize()
  end,
})
