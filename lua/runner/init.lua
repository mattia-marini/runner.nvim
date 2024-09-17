require("runner.autocmd")

local function parseConfig(t1, t2)
  for key, val in pairs(t2) do
    if type(val) == "table" then
      if not t1[key] then t1[key] = {} end
      parseConfig(t1[key], val)
    else
      t1[key] = val
    end
  end
end

return {
  config = function(user_conf)
    local config_table = require("runner.config")
    parseConfig(config_table, user_conf)
  end
}
