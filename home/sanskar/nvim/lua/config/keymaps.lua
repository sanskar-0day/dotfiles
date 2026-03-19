-- ==========================================
-- AI Tool Keymaps
-- ==========================================

local map = vim.keymap.set

-- 1. Avante.nvim (Cursor-like IDE)
map("n", "<leader>aa", "<cmd>AvanteAsk<CR>", { desc = "Avante Ask (Chat with code)" })
map("n", "<leader>ae", "<cmd>AvanteEdit<CR>", { desc = "Avante Edit (Inline AI edit)" })
map("n", "<leader>ar", "<cmd>AvanteRefresh<CR>", { desc = "Avante Refresh" })

-- 2. CodeCompanion (Agentic Chat & Commands)
map({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion Chat Toggle" })
map({ "n", "v" }, "<leader>ca", "<cmd>CodeCompanionActions<CR>", { desc = "CodeCompanion Actions" })
map("n", "<leader>ci", "<cmd>CodeCompanion<CR>", { desc = "CodeCompanion Inline Edit" })

-- 3. Copilot & CopilotChat
map("n", "<leader>ct", "<cmd>CopilotChatToggle<CR>", { desc = "Copilot Chat Toggle" })
map("v", "<leader>cp", ":CopilotChatVisual<CR>", { desc = "Copilot Chat with Selection" })

-- 4. NeoCodeium (Inline Completion)
map("i", "<A-f>", function() return require("neocodeium").accept() end, { expr = true, desc = "NeoCodeium Accept" })
map("i", "<A-w>", function() return require("neocodeium").accept_word() end, { expr = true, desc = "NeoCodeium Accept Word" })
map("i", "<A-e>", function() return require("neocodeium").cycle_or_complete() end, { expr = true, desc = "NeoCodeium Cycle/Complete" })
map("i", "<A-x>", function() return require("neocodeium").clear() end, { expr = true, desc = "NeoCodeium Clear" })

-- ==========================================
-- General Keymaps
-- ==========================================

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Better paste (don't yank replaced text)
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Center screen on search navigation
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Center screen on page navigation
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Save with Ctrl-S
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- Better search and replace
map("n", "<leader>sr", ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- Split windows
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split horizontal" })

-- Toggle line wrapping
map("n", "<leader>w", "<cmd>set wrap!<cr>", { desc = "Toggle line wrapping" })

-- Toggle relative numbers
map("n", "<leader>un", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative numbers" })

-- Toggle conceal level
map("n", "<leader>uc", function()
  local conceal = vim.wo.conceallevel
  vim.wo.conceallevel = conceal == 0 and 2 or 0
end, { desc = "Toggle conceal level" })

-- Increment/decrement numbers
map("n", "+", "<C-a>", { desc = "Increment number" })
map("n", "-", "<C-x>", { desc = "Decrement number" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Terminal
map("n", "<leader>t", "<cmd>terminal<cr>", { desc = "Open terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window from terminal" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to lower window from terminal" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to upper window from terminal" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window from terminal" })

-- Format document
map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format document" })

-- Git
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
