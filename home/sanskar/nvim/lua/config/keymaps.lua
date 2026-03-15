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
-- Alt-f to accept (set in plugins/init.lua already, but making it consistent)
map("i", "<A-f>", function() return require("neocodeium").accept() end, { expr = true, desc = "NeoCodeium Accept" })
map("i", "<A-w>", function() return require("neocodeium").accept_word() end, { expr = true, desc = "NeoCodeium Accept Word" })
map("i", "<A-e>", function() return require("neocodeium").cycle_or_complete() end, { expr = true, desc = "NeoCodeium Cycle/Complete" })
map("i", "<A-x>", function() return require("neocodeium").clear() end, { expr = true, desc = "NeoCodeium Clear" })

-- 5. Standard LazyVim keymaps are already available
-- Use <leader>f to find files, <leader>/ to grep, etc.
