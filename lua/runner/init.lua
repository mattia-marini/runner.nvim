return {
  ---@param user_config RunnerConfig
  setup = function(user_config)
    if user_config == nil then user_config = {} end

    local utils = require("runner.utils")
    local schema_utils = require("runner.config.schema_utils")
    local config = require("runner.config")

    local rv1, rv2 = schema_utils.parse_config(user_config, config.schema)

    if rv1 == false then
      utils.dprint("Could not parse configuration: " .. rv2, vim.log.levels.ERROR)
      return false
    else
      config.config = rv2
      require("runner.autocmd")
    end
  end
}
