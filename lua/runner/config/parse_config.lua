local function parse_config(user_config)
  local utils = require("runner.utils")
  local schema_utils = require("runner.config.schema_utils")

  local cfg = require("runner.config")

  -- print("user_config: ", vim.inspect(user_config))
  local rv1, rv2 = schema_utils.parse_config(user_config, cfg.schema)
  if rv1 == false then
    vim.notify(rv2, vim.log.levels.ERROR)
    return
  end

  cfg.config = rv2
  -- print("Requiring user config: ", vim.inspect(require("runner.config").config))
end


return {
  parse_config = parse_config
}
