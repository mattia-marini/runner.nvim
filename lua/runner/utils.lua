local M = {};

function M.dprint(message, log_level)
  local global_config = M.get_global_config()
  if global_config.debug then
    vim.notify(
      message,
      log_level
    )
  end
end

function M.get_global_config()
  return require("runner.config")[1]
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

return M
