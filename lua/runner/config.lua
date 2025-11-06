---@class RunnerConfig
---@field mappings table<string, function> Key mappings for starting and stopping the runner
---@field debug boolean Enable debug mode
---@field lang table<string, table<string, BuildConfig>> Language specific configurations

---@type RunnerConfig
local M = {
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop,
  },
  debug = false,
  lang = require("runner.defaults")
}


-- _validate is called with the table that contains it as the only argument
-- _values is use to specify the format of values that can be extended by the user
local schema = {
  mappings = {
    _type = { "table" },
    _structure = {
      _values = { _type = { "function" } }
    },
  },
  debug = { _type = { "boolean" } },
  lang = {
    type = { "table" },
    -- table<language, table<build_config_id, BuildConfig>>
    _structure = {
      _values = {
        _type = "table",
        -- table<build_config_id, BuildConfig>
        _structure = {
          _values = {
            _type = { "table" },
            --BuildConfig
            _structure = {
              singleFile = { _type = { "boolean" } },
              root = { _type = { "nil" }, "function" },
              build = { _type = { "function" } },
              run = { _type = { "function" } },
              buildAndRun = { _type = { "function" } },
              mappings = {
                _type = { "table" },
                _values = {
                  _validate = function(this)
                  end
                }
              },
              runargs = {
                _type = { "table" },
                _values = {
                  _validate = function(this)
                    if type(this) ~= "string" then
                      return false, "conf.lang[lang][conf].runargs must be a string"
                    end
                    return true
                  end
                }
              },
              runargsBase = {
                _type = { "function", "string" },
                _validate = function(this)
                  if type(this) == "string" then
                    if this ~= "root" and this ~= "buffer" then
                      return false, "conf.lang[lang][conf].runargsBase must be 'root'|'buffer'|function():string"
                    end
                  end
                  return true
                end
              },
            },
          },
          active_conf = { _type = { "string", "function", "nil" } },
          _validate = function(this)
            if type(this) ~= "table" then
              return false, "conf.lang values must be tables"
            end

            if #this == 1 then return true end

            if this.active_conf == nil then
              return false, "conf.lang.active_conf must be specified if multiple config are present"
            end

            local active_conf_str
            if type(this.active_conf) == "string" then
              active_conf_str = this.active_conf
            elseif type(this.active_conf) == "function" then
              active_conf_str = this.active_conf()
            else
              return false, "conf.lang.active_conf must be string|function():string"
            end

            if this[active_conf_str] == nil then
              return false, "conf.lang.active_conf specifies " .. active_conf_str .. " which is invalid"
            end
          end,
        }
      }
    }
  }
}

return M, schema
