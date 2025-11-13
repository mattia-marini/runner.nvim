local M = {};

function M.dprint(message, log_level, debug)
  if debug == nil then debug = false end

  local global_config = M.get_global_config()
  if not debug or (debug and global_config.debug) then
    vim.notify(
      "[runner.nvim]: " .. message,
      log_level
    )
  end
end

function M.get_global_config()
  return require("runner.config").config
end

function M.is_curr_ft_supported()
  local ft = vim.api.nvim_get_option_value("filetype", {})
  return M.get_global_config().lang[ft] ~= nil
end

function M.is_curr_ft_ignored()
  local ft = vim.api.nvim_get_option_value("filetype", {})
  return M.get_global_config().ignored_fts[ft] ~= nil
end

---@return table<string, BuildConfig>
function M.get_curr_ft_config()
  return M.get_global_config().lang[vim.api.nvim_get_option_value("filetype", {})]
end

---@return BuildConfig?
function M.get_curr_ft_active_config()
  local ft_config = M.get_curr_ft_config()
  if not ft_config then return nil end
  return ft_config[ft_config.active_conf]
end

function M.get_curr_runargs()
  return M.get_curr_ft_active_config().runargs
end

return M
