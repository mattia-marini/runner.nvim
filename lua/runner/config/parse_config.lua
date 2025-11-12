local function parse_config(user_config)
  local utils = require("runner.utils")
  local scheme_utils = require("runner.config.schema")
  local config, schema = unpack(require("runner.config"))

  print("user_config: ", vim.inspect(user_config))
  local rv1, rv2 = scheme_utils.parse_config(user_config, schema)
  if rv1 == false then
    vim.notify(rv2, vim.log.levels.ERROR)
    return
  end
  config = rv2

  print("Finalized conf: ", vim.inspect(config))

  -- scheme_utils.join(config, rv2)
  -- print("Finalized conf: ", vim.inspect(config))
end


return {
  parse_config = parse_config
}
