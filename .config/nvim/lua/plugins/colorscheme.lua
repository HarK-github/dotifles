-- ~/.config/nvim/lua/plugins/colorscheme.lua
--
return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("cyberdream").setup({
      variant = "default", -- "default" | "light" | "auto"
      transparent = true,
      saturation = 1,
      italic_comments = true,
      hide_fillchars = false,
      borderless_pickers = false,
      terminal_colors = true,
      extensions = {}, -- NO unsupported extensions
    })

    -- Apply Cyberdream
    vim.cmd("colorscheme cyberdream")

    -- Optional: Which-Key manual highlights
    vim.api.nvim_set_hl(0, "WhichKey", { fg = "#5ea1ff", bold = true })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#5eff6c", bold = true })
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#ff6e5e" })
  end,
}
