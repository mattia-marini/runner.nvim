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
            runargs = T:new({}):values(T:new("string")),
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
