local constants = require("overseer.constants")
local files = require("overseer.files")
local registry = require("overseer.registry")
local task_editor = require("overseer.task_editor")
local util = require("overseer.util")
local STATUS = constants.STATUS
local SLOT = constants.SLOT

local M = {
  start = {
    condition = function(task)
      return task.status == STATUS.PENDING
    end,
    run = function(task)
      task:start()
    end,
  },
  stop = {
    condition = function(task)
      return task.status == STATUS.RUNNING
    end,
    run = function(task)
      task:stop()
    end,
  },
  save = {
    description = "save the task to a bundle file",
    condition = function(task)
      return true
    end,
    run = function(task)
      local data = task:serialize()
      vim.ui.input({
        prompt = "Task bundle name:",
      }, function(selected)
        if selected then
          local filename = string.format("%s.bundle.json", selected)
          files.write_data_file(filename, { data })
        end
      end)
    end,
  },
  rerun = {
    condition = function(task)
      return task:has_component("rerun_trigger")
        and task.status ~= STATUS.PENDING
        and task.status ~= STATUS.RUNNING
    end,
    run = function(task)
      task:rerun()
    end,
  },
  dispose = {
    condition = function(task)
      return true
    end,
    run = function(task)
      task:dispose(true)
    end,
  },
  edit = {
    condition = function(task)
      return task.status ~= STATUS.RUNNING
    end,
    run = function(task)
      task_editor.open(task, function(t)
        if t then
          registry.update_task(t)
        end
      end)
    end,
  },
  ensure = {
    description = "rerun the task if it fails",
    condition = function(task)
      return true
    end,
    run = function(task)
      task:add_components({ "rerun_trigger", "rerun_on_result" })
      if task.status == STATUS.FAILURE then
        task:rerun()
      end
    end,
  },
  watch = {
    description = "rerun the task when you save a file",
    condition = function(task)
      return task:has_component("rerun_trigger") and not task:has_component("rerun_on_save")
    end,
    run = function(task)
      vim.ui.input({
        prompt = "Directory (watch these files)",
        default = vim.fn.getcwd(0),
      }, function(dir)
        task:remove_by_slot(SLOT.DISPOSE)
        task:set_components({
          { "rerun_trigger", interrupt = true },
          { "rerun_on_save", dir = dir },
        })
        registry.update_task(task)
      end)
    end,
  },
  ["set quickfix diagnostics"] = {
    description = "put the diagnostics results into quickfix",
    condition = function(task)
      return task.result
        and task.result.diagnostics
        and not vim.tbl_isempty(task.result.diagnostics)
    end,
    run = function(task)
      vim.fn.setqflist(task.result.diagnostics)
    end,
  },
  ["set loclist diagnostics"] = {
    description = "put the diagnostics results into loclist",
    condition = function(task)
      return task.result
        and task.result.diagnostics
        and not vim.tbl_isempty(task.result.diagnostics)
    end,
    run = function(task)
      local winid = util.find_code_window()
      vim.fn.setloclist(winid, task.result.diagnostics)
    end,
  },
  ["set quickfix stacktrace"] = {
    description = "put the stacktrace result into quickfix",
    condition = function(task)
      return task.result and task.result.stacktrace and not vim.tbl_isempty(task.result.stacktrace)
    end,
    run = function(task)
      vim.fn.setqflist(task.result.stacktrace)
    end,
  },
  ["set loclist stacktrace"] = {
    description = "put the stacktrace result into loclist",
    condition = function(task)
      return task.result and task.result.stacktrace and not vim.tbl_isempty(task.result.stacktrace)
    end,
    run = function(task)
      local winid = util.find_code_window()
      vim.fn.setloclist(winid, task.result.stacktrace)
    end,
  },
}

return M