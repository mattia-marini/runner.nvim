---@type RunnerCommonArgs
local M = {}

---@class RunnerCommonArgs
---@field curr_file fun(): string Current file path
---@field curr_file_dir fun(): string Current file dirname
---@field curr_file_name fun(): string Current file basename
---@field runargs fun(): table<string,string> The arguments provided by the user via :Runargs

local utils = require("runner.utils")

function M.curr_file() return vim.api.nvim_buf_get_name(0) end

function M.curr_file_dir() return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) end

function M.curr_file_name() return vim.fs.basename(vim.api.nvim_buf_get_name(0)) end

function M.runargs()
  local ft_config = utils.get_curr_ft_config()
  if ft_config == nil then return {} end
  if #ft_config == 1 then
    for _, config in pairs(ft_config) do return config.runargs end
  end

  local active_conf_id = ft_config.active_conf
  if active_conf_id == nil then
    utils.dprint("You must provide a lang.active_conf key if you have multiple configurations defined",
      vim.log.levels.ERROR)
    return {}
  end

  local active_conf = ft_config[active_conf_id]
  if active_conf == nil then
    utils.dprint("Invalid lang.active_conf key. The provided key does not match any configuration", vim.log.levels.ERROR)
    return {}
  end

  return active_conf.runargs
end

return M
