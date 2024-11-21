local function addDefaults(t1, t2)
  if not t2.lang then return end
  for key, _ in pairs(t2.lang) do
    if not t1.lang[key] then -- If there is no default then I use an empty template
      t1.lang[key] = require("runner.defaults.common").new()
    end
  end
end

-- Merges t2 values into t1
local function join(t1, t2)
  -- print(t1, t2)
  if t1._extensible == true then
    -- Right join, can add values
    for key, val in pairs(t2) do
      if type(val) == "table" then
        if not t1[key] then t1[key] = { extensible = true } end -- extensible = true since having it disabled would cause to ignore each table
        join(val, t2[key])
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

-- Wrapper around parseConfigRec
local function parseConfig(t1, t2)
  addDefaults(t1, t2) -- Adds defaults for languages of t2 in t1
  join(t1, t2)        -- Merges t2 into t1
end


return {
  parseConfig = parseConfig
}
