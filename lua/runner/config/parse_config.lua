local function parseConfig(user_config)
  local utils = require("runner.utils")
  local scheme_utils = require("runner.config.schema")

  local config, schema = unpack(require("runner.config.config"))
  local rv1, rv2 = scheme_utils.parse_config(user_config, schema)
  if rv1 == false then
    utils.dprint(rv2, vim.log.levels.ERROR)
    return
  end

  scheme_utils.join(config, rv2)
  -- print("Finalized conf: ", vim.inspect(config))
end


return {
  parseConfig = parseConfig
}
