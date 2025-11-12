local M = {}

function M.get()
  local curr_active_config = require("runner.utils").get_curr_ft_active_config()
  if not curr_active_config then
    require("runner.utils").dprint("Cannot get current config", vim.log.levels.ERROR)
    return nil
  end
  return curr_active_config.runargs
end

return M
