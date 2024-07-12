require("runner.autocmd")

return {
  config = function(user_conf)
    local config_table = require("runner.config")
    for key, value in pairs(user_conf) do
      config_table[key] = value
    end
  end
}
