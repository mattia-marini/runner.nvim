local M = {}

function M.get()
  local config = require("runner.utils").get_curr_ft_active_config()
  if not config then
    require("runner.utils").dprint("Cannot get current config", vim.log.levels.ERROR)
    return nil
  end
  return config.runargs
end

return M
