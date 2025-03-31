return {
  setup = function(user_conf)
    local config_table = require("runner.config")
    require("runner.parse_config").parseConfig(config_table, user_conf)
    require("runner.autocmd")
  end
}
