--- Util to validate and parse user config

local T = {}
T.__index = T

function T.check(config_key, config, schema, path)
  -- print(path)
  if schema._type == "union" then
    local curr_type_schema = schema._union_types[type(config)]
    if curr_type_schema == nil then
      local union_types = {}
      for k in pairs(schema._union_types) do table.insert(union_types, k) end
      table.sort(union_types)

      return false, "Value at " .. path .. " should be one of " .. table.concat(union_types, "|")
    end

    if curr_type_schema ~= nil then
      local rv, msg = T.check(config_key, config, curr_type_schema, path)
      if rv == false then return false, msg end
    end
  elseif schema._type == "table" then
    if type(config) ~= "table" then
      return false, "Value at " .. path .. " should be a table"
    end
    local config_keys = {}
    for key, val in pairs(config) do
      config_keys[key] = true

      -- Unresolved key in config
      if schema._t_struct[key] == nil and schema._values == nil then
        return false, "Unresolved key: " .. key .. "(" .. path .. ")"
      end

      -- User added keys
      if schema._t_struct[key] == nil then
        -- Unresolved key in config
        if schema._values == nil then
          return false, "Unresolved key: " .. key .. "(" .. path .. ")"
        end

        -- Values are checked against T type
        if getmetatable(schema._values) == T then
          local rv, msg = T.check(key, config[key], schema._values, path .. "." .. key)
          if rv == false then return false, msg end
        end
      end

      -- Schema defined keys
      if schema._t_struct[key] ~= nil then
        local rv, msg = T.check(key, config[key], schema._t_struct[key], path .. "." .. key)
        if rv == false then return false, msg end
      end
    end

    for key, val in pairs(schema._t_struct) do
      if schema._t_struct[key]._required == true and config_keys[key] == nil then
        return false, "Missing required key: " .. path .. "." .. key
      end
    end
  elseif type(config) ~= "any" then
    if type(config) ~= schema._type then
      return false, "Value at " .. path .. " should be " .. schema._type
    end
  end

  if schema._validate ~= nil then
    local rv, msg = schema._validate(config_key, config, path)
    if msg == nil then msg = "" else msg = ": " .. msg end
    if rv == false then return false, "Validation failed at " .. path .. msg end
  end

  return true, "Schema is valid"
end

function T:new(...)
  local rv = {}

  if select("#", ...) == 0 then error("T:new requires at least one argument") end

  -- Simple type (table or primitive)
  if select("#", ...) == 1 then
    local first_arg = select(1, ...)
    if type(first_arg) == "table" then
      rv = {
        _type = "table",
        _t_struct = first_arg
      }
    elseif type(first_arg) == "string" then
      rv = { _type = first_arg }
    else
      error("Invalid argument to T:new")
    end
  else -- Union type
    rv = { _type = "union", _union_types = {} }
    for i, t in ipairs({ ... }) do
      if getmetatable(t) ~= T then error("Invalid argument to T:new") end
      rv._union_types[t._type] = t
    end
  end

  return setmetatable(rv, self)
end

-- Define the structure of the values that can be added from the config, but are not present in the schema
function T:values(structure)
  self._values = structure
  return self
end

function T:validate(validate)
  self._validate = validate
  return self
end

function T:required(required)
  if required == nil then required = true end
  self._required = required
  return self
end

function T.is_valid_type(t_string)
  return t_string == "nil" or
      t_string == "number" or
      t_string == "string" or
      t_string == "boolean" or
      t_string == "table" or
      t_string == "function" or
      t_string == "thread" or
      t_string == "userdata" or
      t_string == "union" -- does not actually exist
end
