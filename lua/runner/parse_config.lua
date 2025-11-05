local function addDefaults(t1, t2)
  if not t2.lang then return end
  for key, _ in pairs(t2.lang) do
    if not t1.lang[key] then -- If there is no default then I use an empty template
      t1.lang[key] = require("lua.runner.defaults.config.common").new()
    end
  end
end

-- Merges t2 values into t1
local function join(t1, t2, schema)
  -- print(t1, t2)
  if schema._extendable == true then
    -- Right join, can add values
    for key, val in pairs(t2) do
      if type(val) == "table" then
        if not t1[key] then t1[key] = {} end
        if not schema[key] then schema[key] = { _extendible = true } end
        join(t1[key], val)
      else
        t1[key] = t2[key]
      end
    end
  else
    -- Left join, can't add values, default
    for key, val in pairs(t1) do
      if t2[key] then
        if type(val) == "table" then
          join(val, t2[key])
        else
          t1[key] = t2[key]
        end
      end
    end
  end
end


local function parseConfig(user_conf)
  local conf, schema = require("runner.config")
  addDefaults(conf, user_conf) -- Adds defaults for languages of t2 in t1
  join(t1, user_conf, schema)  -- Merges t2 into t1
end


return {
  parseConfig = parseConfig
}
