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

return M
