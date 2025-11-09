---@class T
---@field _type string The type of the schema (e.g., "union", "table", "string", "number", etc.)
---@field _union_types table<string, T>? Map of type names to their schemas for union types
---@field _t_struct table<string, T>? Map of field names to their schemas for table types
---@field _values T? Schema for dynamic values in tables
---@field _validate fun(config_key: any, config: any, path: string): boolean, string? Additional validation function
---@field _map fun(config_key: any, parsed_config: any, path: string): any Function to map the value
---@field _required boolean? Whether this field is required
local T = {}
T.__index = T

---Check if a config matches the schema and parses it, applying any mapping functions
---@param config any The config value to check
---@param schema T The schema to validate against
---@return boolean success Whether the validation succeeded
---@return any result Either the parsed config on success or an error message on failure
function T.parse_config(config, schema)
  ---@diagnostic disable-next-line: redefined-local
  local function parse_config_rec(config_key, config, schema, path)
    local parsed_config = nil

    if schema._type == "union" then
      local curr_type_schema = schema._union_types[type(config)]
      if curr_type_schema == nil then
        local union_types = {}
        for k in pairs(schema._union_types) do table.insert(union_types, k) end
        table.sort(union_types)

        return false, "Value at " .. path .. " should be one of " .. table.concat(union_types, "|")
      end

      if curr_type_schema ~= nil then
        local rv, rv2 = parse_config_rec(config_key, config, curr_type_schema, path)
        if rv == false then return false, rv2 end
        parsed_config = rv2
      end
    elseif schema._type == "table" then
      parsed_config = {}
      if type(config) ~= "table" then
        return false, "Value at " .. path .. " should be a table"
      end
      local config_keys = {}
      for key, val in pairs(config) do
        config_keys[key] = true

        -- User added keys
        if schema._t_struct[key] == nil then
          -- Unresolved key in config
          if schema._values == nil then
            return false, "Unresolved key: " .. key .. "(" .. path .. ")"
          end

          -- Values are checked against T type
          if getmetatable(schema._values) == T then
            local rv, rv2 = parse_config_rec(key, config[key], schema._values, path .. "." .. key)
            if rv == false then return false, rv2 end
            parsed_config[key] = rv2
          end
        end

        -- Schema defined keys
        if schema._t_struct[key] ~= nil then
          local rv, rv2 = parse_config_rec(key, config[key], schema._t_struct[key], path .. "." .. key)
          if rv == false then return false, rv2 end
          parsed_config[key] = rv2
        end
      end

      for key, val in pairs(schema._t_struct) do
        if schema._t_struct[key]._required == true and config_keys[key] == nil then
          return false, "Missing required key: " .. path .. "." .. key
        end
      end
    elseif type(config) == "any" then
      parsed_config = config
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
      rv._union_types[t._type] = t
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

---Mark this field as required or optional
---@param required boolean? Whether this field is required (defaults to true)
---@return T self Returns self for method chaining
function T:required(required)
  if required == nil then required = true end
  self._required = required
  return self
end

---Set a mapping function to transform the parsed value
---@param map fun(config_key: any, parsed_config: any, path: string): any Function to transform the parsed config
---@return T self Returns self for method chaining
function T:map(map)
  self._map = map
  return self
end

return T
