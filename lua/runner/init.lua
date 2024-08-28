require("runner.autocmd")

local function parseConfig(t1, t2)
  for key, val in pairs(t2) do
    if type(val) == "table" then
      t1[key] = t1[key] and t1[key] or {}
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
