return {
  ---@param user_conf RunnerConfig
  setup = function(user_conf)
    if user_conf == nil then user_conf = {} end
    require("runner.config.parse_config").parse_config(user_conf)
    require("runner.autocmd")
  end
}
