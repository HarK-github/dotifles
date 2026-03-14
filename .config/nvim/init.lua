-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- Copy/paste from system clipboard
vim.keymap.set({ "n", "x" }, "cp", '"+y')
vim.keymap.set({ "n", "x" }, "cv", '"+p')
-- Delete without changing the registers
vim.keymap.set({ "n", "x" }, "x", '"_x')
vim.api.nvim_set_keymap(
  "n",
  "<leader>r",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { noremap = true, silent = false }
)

-- Enable automatic indentation
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.cindent = true
vim.o.tabstop = 4 -- Number of spaces for a tab
vim.o.shiftwidth = 4 -- Number of spaces to use for autoindent
vim.o.expandtab = false -- Use real tabs instead of spaces
--Lua:
-- Fix right-click context menu in insert mode
vim.keymap.set("v", "<RightMouse>", "<C-\\><C-g>gv<cmd>popup! PopUp<cr>", { noremap = true })
-- Other configurations...

-- Right-click fix
vim.keymap.set("v", "<RightMouse>", "<C-\\><C-g>gv<cmd>popup! PopUp<cr>", { noremap = true })
-- Define a simple context menu (optional)
vim.api.nvim_create_user_command("PopUp", function()
  vim.ui.select({ "Copy", "Paste", "Cut" }, { prompt = "Context Menu:" }, function(choice)
    if choice == "Copy" then
      vim.cmd("normal! y")
    end
    if choice == "Paste" then
      vim.cmd("normal! p")
    end
    if choice == "Cut" then
      vim.cmd("normal! d")
    end
  end)
end, {})
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  command = "0r ~/.config/nvim/templates/skeleton.cpp",
})

require("toggleterm").setup({
  size = 10,
  open_mapping = [[<C-\>]], -- Press Ctrl+\ to toggle terminal
  shade_terminals = true,
  direction = "float", -- "horizontal" | "vertical" | "tab" | "float"
  float_opts = {
    border = "curved",
  },
})

local Terminal = require("toggleterm.terminal").Terminal

function CompileAndRunCpp()
  vim.cmd("w") -- Save file
  local file = vim.fn.expand("%")
  local output = vim.fn.expand("%:r")
  local input_file = "input.txt"

  local cmd
  if vim.fn.filereadable(input_file) == 1 then
    -- Use input.txt if it exists
    cmd = string.format(
      "g++ -std=c++17 -Wall -O2 %s -o %s && ./%s < %s && echo '\n[Process exited]'; read",
      file,
      output,
      output,
      input_file
    )
  else
    -- Otherwise, just compile and run normally
    cmd = string.format(
      "g++ -std=c++17 -Wall -O2 %s -o %s && ./%s && echo '\n[Process exited]'; read",
      file,
      output,
      output
    )
  end

  if _G.cpp_term and _G.cpp_term:is_open() then
    _G.cpp_term:close()
  end
  _G.cpp_term = Terminal:new({
    cmd = cmd,
    hidden = true,
    direction = "float",
    close_on_exit = false,
  })
  _G.cpp_term:toggle()
end
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  command = "0r ~/.config/nvim/templates/cpp.tmpl",
})

vim.keymap.set("n", "<F5>", CompileAndRunCpp, { noremap = true, silent = true })
