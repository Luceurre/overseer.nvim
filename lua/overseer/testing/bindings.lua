local binding_util = require("overseer.binding_util")

local M

M = {
  {
    lhs = "?",
    mode = "n",
    desc = "Show default key bindings",
    plug = "<Plug>OverseerTest:ShowHelp",
    rhs = function()
      binding_util.show_bindings(M)
    end,
  },
  {
    lhs = "<CR>",
    mode = "n",
    desc = "Open test action menu",
    plug = "<Plug>OverseerTest:RunAction",
    rhs = function(panel)
      panel:run_action()
    end,
  },
  {
    lhs = "<C-r>",
    mode = "n",
    desc = "Rerun test",
    plug = "<Plug>OverseerTest:Rerun",
    rhs = function(panel)
      panel:run_action("rerun")
    end,
  },
  {
    lhs = "<C-s>",
    mode = "n",
    desc = "Set stacktrace to quickfix",
    plug = "<Plug>OverseerTest:Stacktrace",
    rhs = function(panel)
      panel:run_action("set quickfix stacktrace")
    end,
  },
  {
    lhs = "p",
    mode = "n",
    desc = "Toggle test result preview window",
    plug = "<Plug>OverseerTest:TogglePreview",
    rhs = function(panel)
      panel:toggle_preview()
    end,
  },
  {
    lhs = "[",
    mode = "n",
    desc = "Decrease window width",
    plug = "<Plug>OverseerTest:DecreaseWidth",
    rhs = function()
      local width = vim.api.nvim_win_get_width(0)
      vim.api.nvim_win_set_width(0, math.max(10, width - 10))
    end,
  },
  {
    lhs = "]",
    mode = "n",
    desc = "Increase window width",
    plug = "<Plug>OverseerTest:IncreaseWidth",
    rhs = function()
      local width = vim.api.nvim_win_get_width(0)
      vim.api.nvim_win_set_width(0, math.max(10, width + 10))
    end,
  },
}

return M