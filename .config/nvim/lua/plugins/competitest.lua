return {
  "xeluxee/competitest.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function()
    require("competitest").setup({})
  end,
  keys = {
    -- Testcase management
    { "<leader>za", "<cmd>CompetiTest add_testcase<cr>", desc = "Add testcase" },
    { "<leader>ze", "<cmd>CompetiTest edit_testcase<cr>", desc = "Edit testcase" },
    { "<leader>zd", "<cmd>CompetiTest delete_testcase<cr>", desc = "Delete testcase" },

    -- Run / UI
    { "<leader>zr", "<cmd>CompetiTest run<cr>", desc = "Run testcases" },
    { "<leader>zR", "<cmd>CompetiTest run_no_compile<cr>", desc = "Run (no compile)" },
    { "<leader>zs", "<cmd>CompetiTest show_ui<cr>", desc = "Show results UI" },

    -- Receive (Competitive Companion)
    { "<leader>zl", "<cmd>CompetiTest receive problem<cr>", desc = "Load problem" },
    { "<leader>zt", "<cmd>CompetiTest receive testcases<cr>", desc = "Load testcases" },
    { "<leader>zC", "<cmd>CompetiTest receive contest<cr>", desc = "Load contest" },

    -- Persistent receive
    { "<leader>zp", "<cmd>CompetiTest receive persistently<cr>", desc = "Receive persistently" },
    { "<leader>zx", "<cmd>CompetiTest receive stop<cr>", desc = "Stop receiving" },
    { "<leader>z?", "<cmd>CompetiTest receive status<cr>", desc = "Receive status" },
  },
}
