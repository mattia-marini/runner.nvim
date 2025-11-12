---@class RunnerConfig
---@field mappings table<string, function> Key mappings for starting and stopping the runner
---@field debug boolean Enable debug mode
---@field ignored_fts table<string, boolean> Filetypes on which runner.nvim should not activate
---@field lang table<string, table<string, BuildConfig>> Language specific configurations

---@type RunnerConfig
local config = {
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop,
  },
  ignored_fts = {
    oil = true,
    cmp_menu = true,
  },
  debug = false,
  lang = require("runner.lang")
}

local T = require("runner.config.schema")

local schema = T:new({
  mappings = T:new({}):values(T:new("function")),
  debug = T:new("boolean"),
  ignored_fts = T:new({}):values(T:new("boolean"):map(function() return true end)),
  lang = T:new({})
      :values(
        T:new({
          active_conf = T:new("string")
        })
        :values(T:new({
            root = T:new("function"),
            build = T:new("function"),
            run = T:new("function"),
            buildAndRun = T:new("function"),
            mappings = T:new({}):values(T:new("function")),
            runargs = T:new({})
                :values(
                -- TODO add string[] as supported value
                  T:new(
                    T:new("string"),
                    T:new("boolean"),
                    T:new({
                      value = T:new(T:new("string"), T:new("boolean"), T:new({}):values(T:new("string"))):required(),
                      default = T:new(T:new("string"), T:new("boolean")):required(),
                      complete = T:new("function"),
                      check = T:new("function"),
                      map = T:new("function"),
                    })
                  )
                  :map(function(key, val, path)
                    local t_value
                    local t_default
                    local t_complete = function(arglead, cmdline, cursorpos) return {} end
                    local t_check = function(value) return true end
                    local t_map = function(value) return value end

                    if type(val) == "string" then -- string
                      t_value = val
                      t_default = val
                    elseif type(val) == "boolean" then -- boolean
                      t_value = val
                      t_default = val
                      t_complete = function(arglead, cmdline, cursorpos) return { "true", "false" } end
                      t_check = function(value) return value == "true" or value == "false" or value == "" end
                      t_map = function(value)
                        if value == "true" then
                          return true
                        elseif value == "false" then
                          return false
                        elseif value == "" then
                          return true
                        else
                          return value
                        end
                      end
                    elseif type(val) == "table" then --table
                      t_value = val.value
                      t_default = val.default
                      if val.complete == nil then
                        if type(val.value) == "boolean" then
                          t_complete = function(arglead, cmdline, cursorpos) return { "true", "false" } end
                        elseif type(val.value) == "string" then
                        end
                      end
                      if val.check == nil then
                        if type(val.value) == "boolean" then
                          t_check = function(value) return value == "true" or value == "false" or value == "" end
                        elseif type(val.value) == "string" then
                        end
                      end
                    end

                    return {
                      value = t_value,
                      default = t_default,
                      complete = t_complete,
                      check = t_check,
                      map = t_map
                    }
                  end)
                ),
            runargsBase = T:new("string")
          })
          :map(function(key, val, path)
            local base_conf = require("runner.lang.common").new()
            T.join(base_conf, val)
            return base_conf
          end)
        )
        :validate(
          function(key, val, path)
            local n_languages = 0
            for k, v in pairs(val) do if k ~= "active_conf" then n_languages = n_languages + 1 end end
            if n_languages > 1 and val.active_conf == nil then
              return false, path .. " requires an active_conf key when multiple configurations are defined"
            end
            if val.active_conf ~= nil and val[val.active_conf] == nil then
              return false, path .. " has no conf named \"" .. val.active_conf .. "\""
            end
            return true
          end)
      )
})

return { config, schema }
