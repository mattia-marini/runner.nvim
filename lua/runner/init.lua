return {
  ---@param user_conf RunnerConfig
  setup = function(user_conf)
    require("runner.config.parse_config").parseConfig(user_conf)
    require("runner.autocmd")
  end
}
