-- Options (LazyVim defaults are already sensible, these are overrides)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- ── Line Numbers ─────────────────────────────────────────
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

-- ── Indentation ──────────────────────────────────────────
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

-- ── Search ───────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- ── Appearance ───────────────────────────────────────────
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.colorcolumn = "80,120"
opt.showmode = false
opt.ruler = false
opt.laststatus = 3  -- Global statusline
opt.cmdheight = 1

-- ── Splits ───────────────────────────────────────────────
opt.splitbelow = true
opt.splitright = true

-- ── Clipboard ────────────────────────────────────────────
opt.clipboard = "unnamedplus"

-- ── Files ────────────────────────────────────────────────
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- ── Completion ───────────────────────────────────────────
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- ── Performance ──────────────────────────────────────────
opt.updatetime = 250
opt.timeoutlen = 300

-- ── Miscellaneous ────────────────────────────────────────
opt.mouse = "a"
opt.virtualedit = "block"
opt.wildmode = { "longest:full", "full" }
opt.confirm = true
opt.exrc = true  -- Allow local .nvim.lua files
opt.secure = true  -- But only safe commands in local .nvim.lua
