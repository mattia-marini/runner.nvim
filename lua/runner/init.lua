require("runner.autocmd")

-- Adds default a default language config so that the plugin does not create problems in case of non supported languages
local function addDefaults(t1, t2)
  for key, _ in pairs(t2) do
    local defaultExists, defaultConfig = pcall(function() require("runner.defaults." .. key) end)
    if defaultExists then
      t1[key] = defaultConfig
    else
      t1[key] = require("runner.defaults.common").new()
    end
  end
end

-- Merges t2 values in t1
local function parseConfig(t1, t2)
  for key, val in pairs(t2) do
    if key == "lang" then addDefaults(t1[key], val) end

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
