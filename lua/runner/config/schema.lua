---@class T
---@field _type string The type of the schema (e.g., "union", "table", "string", "number", etc.)
---@field _union_types table<string, T>? Map of type names to their schemas for union types
---@field _t_struct table<string, T>? Map of field names to their schemas for table types
---@field _values T? Schema for dynamic values in tables
---@field _validate fun(config_key: any, config: any, path: string): boolean, string? Additional validation function
---@field _map fun(config_key: any, parsed_config: any, path: string): any Function to map the value
local T = {}
T.__index = T

local inspect = require("inspect").inspect

local function set_union(set1, set2)
  local rv = {}
  for k, v in pairs(set1) do rv[k] = v end
  for k, v in pairs(set2) do rv[k] = v end
  return rv
end

---Check if a config matches the schema and parses it, applying any mapping functions
---@param config any The config value to check
---@param schema T The schema to validate against
---@return boolean success Whether the validation succeeded
---@return any result Either the parsed config on success or an error message on failure
function T.parse_config(config, schema)
  ---@diagnostic disable-next-line: redefined-local
  local function parse_config_rec(config_key, config, schema, path)
    -- print(path)
    local parsed_config = nil

    if config == nil then
      if schema._default ~= nil then config = schema._default end
      if schema._dyn_default ~= nil then config = schema._dyn_default(config_key, path) end
    end

    if config == nil then
      return false, "Missing required key: " .. path
    end

    --
    --
    --
    --
    -- Union type
    if schema._type == "union" then
      local curr_type_schemas = schema._union_types[type(config)]
      if curr_type_schemas == nil then
        local union_types = {}
        for k in pairs(schema._union_types) do table.insert(union_types, k) end
        table.sort(union_types)

        return false, "Value at " .. path .. " should be one of " .. table.concat(union_types, "|")
      end

      local has_matching_schema = false
      for _, curr_type_schema in ipairs(curr_type_schemas) do
        local rv, rv2 = parse_config_rec(config_key, config, curr_type_schema, path)
        if rv == true then
          has_matching_schema = true
          parsed_config = rv2
          break;
        end
      end
      if not has_matching_schema then
        return false, "Value at " .. path .. " does not match any schema in the union"
      end
      --
      --
      --
      --
      -- Table type
    elseif schema._type == "table" then
      parsed_config = {}
      if type(config) ~= "table" then
        return false, "Value at " .. path .. " should be a table"
      end

      local schema_defined_keys, user_added_keys = {}, {}
      for key, key_schema in pairs(schema._t_struct) do schema_defined_keys[key] = true end
      for key, val in pairs(config) do if schema_defined_keys[key] == nil then user_added_keys[key] = val end end

      local default_values = nil
      if schema._default_values ~= nil then default_values = schema._default_values end
      if schema._dyn_default_values ~= nil then default_values = schema._dyn_default_values() end -- Prefer dyn values if present

      if default_values ~= nil and schema._values == nil then
        return false, "No schema defined for dynamic values at " .. path
      end

      local default_values_keys = {}
      if default_values ~= nil then
        for key, val in pairs(default_values) do
          -- Add only if not present, prefer user values
          if not user_added_keys[key] and not schema_defined_keys[key] then
            default_values_keys[key] = true
            config[key] = val
          end
        end
      end

      for schema_key in pairs(schema_defined_keys) do
        local rv, rv2 = parse_config_rec(schema_key, config[schema_key], schema._t_struct[schema_key],
          path .. "." .. schema_key)
        if rv == false then return false, rv2 end
        parsed_config[schema_key] = rv2
      end


      for added_key, _ in pairs(set_union(user_added_keys, default_values_keys)) do
        local rv, rv2 = parse_config_rec(added_key, config[added_key], schema._values,
          path .. "." .. added_key)
        if rv == false then return false, rv2 end
        parsed_config[added_key] = rv2
      end
      --
      --
      --
      --
      -- Any type
    elseif schema._type == "any" then
      parsed_config = config
      --
      --
      --
      --
      -- Atomic type
    else
      if type(config) ~= schema._type then
        return false, "Value at " .. path .. " should be " .. schema._type
      end
      parsed_config = config
    end

    if schema._validate ~= nil then
      local rv, msg = schema._validate(config_key, config, path)
      if msg == nil then msg = "" else msg = ": " .. msg end
      if rv == false then return false, "Validation failed at " .. path .. msg end
    end

    if schema._map ~= nil then
      parsed_config = schema._map(config_key, parsed_config, path)
    end

    return true, parsed_config
  end

  return parse_config_rec("root", config, schema, "root")
end

---Create a new type schema
---@param ... T|table|string Either a table schema, a primitive type name, or multiple T instances for a union type
---@return T schema The new schema
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
      if rv._union_types[t._type] == nil then rv._union_types[t._type] = {} end
      table.insert(rv._union_types[t._type], t)
    end
  end

  return setmetatable(rv, self)
end

---Define the structure of the values that can be added from the config, but are not present in the schema
---@param structure T The schema for dynamic values
---@return T self Returns self for method chaining
function T:values(structure)
  self._values = structure
  return self
end

---Set a validation function for this schema
---@param validate fun(config_key: any, config: any, path: string): boolean, string? Validation function that returns success and optional error message
---@return T self Returns self for method chaining
function T:validate(validate)
  self._validate = validate
  return self
end

---Set a mapping function to transform the parsed value
---@param map fun(config_key: any, parsed_config: any, path: string): any Function to transform the parsed config
---@return T self Returns self for method chaining
function T:map(map)
  self._map = map
  return self
end

--- Set a default value for this schema
---@param default_value any The default value to use if none is provided
---@return T self Returns self for method chaining
function T:default(default_value)
  self._default = default_value
  return self
end

--- Set a dynamic default value for this schema
---@param dyn_default_value function(config_key: string, path: string):any
---@return T self Returns self for method chaining
function T:dyn_default(dyn_default_value)
  self._dyn_default = dyn_default_value
  return self
end

--- Set a default value for this schema
---@param default_values any The default value to use if none is provided
---@return T self Returns self for method chaining
function T:default_values(default_values)
  self._default_values = default_values
  return self
end

--- Set values to be inserted into a table implementing values
---@param dyn_default_values function(config_key: string, path: string):any
---@return T self Returns self for method chaining
function T:dyn_default_values(dyn_default_values)
  self._dyn_default_values = dyn_default_values
  return self
end

---Recursively merges values from `user_config` into `config`.
---If a value in `user_config` is a table, it merges tables recursively. Otherwise, it overrides the value in `config`.
---@param config table # The base config to merge values into (modified in place)
---@param user_config table # The user-supplied config to merge in
function T.join(config, user_config)
  for key, val in pairs(user_config) do
    if type(val) == "table" then
      if not config[key] then config[key] = {} end
      T.join(config[key], val)
    else
      config[key] = user_config[key]
    end
  end
end
