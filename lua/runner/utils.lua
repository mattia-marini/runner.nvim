local M = {};
local global_config = require("runner.config")

function M.dprint(message, log_level)
  if global_config.debug then
    vim.notify(
      message,
      log_level
    )
  end
end

---@return table<string, BuildConfig>
function M.get_curr_ft_config()
  return require("runner.config").lang[vim.api.nvim_get_option_value("filetype", {})]
end

return M
