return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    opts = {
      ensure_installed = { "cpp" }, -- only C++ parser
    },
  },

  -- LSP installer
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "clangd" },
    },
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").clangd.setup{}
    end,
  },

  -- Formatting
  {
    "mhartington/formatter.nvim",
    config = function()
      require("formatter").setup{
        filetype = {
          cpp = {
            function()
              return {
                exe = "clang-format",
                args = {"-assume-filename", vim.api.nvim_buf_get_name(0)},
                stdin = true
              }
            end
          }
        }
      }
    end
  },
} 

