-- Language-specific plugin configurations for LazyVim
-- LSPs, formatters, linters, and DAP are provided by Nix (nvim.nix)
return {
  -- ── Treesitter: add all language grammars ───────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python", "zig", "nim", "commonlisp",
        "lua", "nix", "bash", "json", "yaml", "toml", "markdown",
        "javascript", "typescript", "html", "css",
        "c", "cpp", "rust", "go", "racket",
        "typst", "vim", "vimdoc", "query", "regex",
      },
    },
  },

  -- ── LSP: configure all language servers ─────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ruff = {},  -- Python linting/formatting LSP

        -- Zig
        zls = {},

        -- Nim
        nim_langserver = {},

        -- Nix
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = { command = { "nixfmt" } },
            },
          },
        },

        -- Lua
        lua_ls = {},

        -- TOML
        taplo = {},

        -- YAML
        yamlls = {},

        -- Markdown
        marksman = {},

        -- TypeScript
        ts_ls = {},

        -- HTML/CSS/JSON
        jsonls = {},
        html = {},
        cssls = {},
      },
    },
  },

  -- ── Formatting: conform.nvim ────────────────────────────────
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "black" },
        lua = { "stylua" },
        nix = { "nixfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        zig = { "zigfmt" },
        typst = { "typstyle" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },

  -- ── Linting: nvim-lint ──────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },

  -- ── Debugging: nvim-dap ─────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      -- Python DAP setup
      local ok, dap_python = pcall(require, "dap-python")
      if ok then
        dap_python.setup("python3")
      end
    end,
  },

  -- ── Common Lisp (SLIME-like REPL & Parinfer) ─────────────
  {
    "vlime/vlime",
    ft = { "lisp", "commonlisp" },
    config = function()
      vim.g.vlime_cl_impl = "sbcl"
    end,
  },
  {
    "gpanders/nvim-parinfer",
    ft = { "lisp", "commonlisp", "clojure", "scheme", "racket", "fennel" },
  },

  -- ── Nim support ─────────────────────────────────────────────
  { "alaviss/nim.nvim", ft = "nim" },

  -- ── Zig extras ──────────────────────────────────────────────
  {
    "ziglang/zig.vim",
    ft = "zig",
    config = function()
      vim.g.zig_fmt_autosave = 1
    end,
  },

  -- ── Typst support ──────────────────────────────────────────
  {
    "kaarmu/typst.vim",
    ft = "typst",
  },
}
