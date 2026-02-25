return {
  {
    "akinsho/toggleterm.nvim",
    tag = "v2.13.1",
    opts = {
      size = 20,
      direction = "float",
      float_opts = {
        border = "curved",
        title_pos = "center",
      },
      hide_numbers = true,
      insert_mappings = true,
      terminal_mappings = true,
    },
    keys = {
      {
        "<leader>td",
        "<cmd>ToggleTerm<cr>",
        desc = "Open a floating terminal",
      },
    },
  },
}
