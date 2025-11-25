---@class RunnerConfig
---@field run_mode RunnerRunMode Configuration for how to run commands
---@field mappings table<string, function> Key mappings for starting and stopping the runner
---@field debug boolean Enable debug mode
---@field ignored_fts table<string, boolean> Filetypes on which runner.nvim should not activate
---@field lang table<string, table<string, BuildConfig>> Language specific configurations

---@class RunnerRunMode
---@field mode "neovim"|"kitty"
---@field opts RunnerRunModeNeovim|RunnerRunModeKitty

---@class RunnerRunModeKitty
---@field shell "fish"|"bash"|"zsh"|"sh"|string
---@field type "background"|"clipboard"|"os-panel"|"os-window"|"overlay"|"overlay-main"|"primary"|"tab"|"window"
---@field title? string|function():string
---@field cwd? string|"current"|function():string
---@field hold? boolean
---@field keep_focus? boolean
---@field copy_env? boolean
---@field other? string|string[] Other kitty options
---@field custom? function(cmd: string, open_kitty_window_pid:number?):string[] A command that overrides the options above. Receives the command to run as argument and must return the full command to execute.

---@class RunnerRunModeNeovim

---@type RunnerConfig
local config = {}

local T = require("runner.config.schema_utils")

local schema = T:new({
  run_mode = T:new({
    mode = T:new("string"):default("kitty"),
    opts = T:new({
      shell = T:new("string"):default("fish"),
      type = T:new("string"):default("tab"),
      title = T:new("string"):default("runner.nvim"),
      cwd = T:new("string"):default("current"),
      hold = T:new("boolean"):default(true),
      keep_focus = T:new("boolean"):default(false),
      copy_env = T:new("boolean"):default(true),
      custom = T:new(T:new("function"), T:new("nil")):default(nil),
      other = T:new(
        T:new("string"),
        T:new({}):values(T:new("string"))
      ):default(""),
    })
  }),
  mappings = T:new({}):values(T:new("function"))
      :default_values({
        ["<Space>r"] = require("runner.run").start,
        ["<Space>R"] = require("runner.run").stop,
      }),
  debug = T:new("boolean"):default(false),
  ignored_fts = T:new({})
      :values(
        T:new("boolean")
        :map(function(_, parsed_config, _)
          if parsed_config == false then return nil else return true end
        end)
      )
      :default_values({ oil = true, cmp_menu = true }),
  lang = T:new({})
      :values(
        T:new({
          active_conf = T:new(T:new("string"), T:new("nil")):default(nil)
        })
        :values(T:new({
            single_file = T:new("boolean"):default(false),
            root = T:new("function"):default(function() return nil end),
            build = T:new("function"):default(function() return "" end),
            run = T:new("function"):default(function() return "" end),
            build_and_run = T:new("function"):default(function() return "" end),
            mappings = T:new({}):values(T:new("function")),
            init = T:new("function"):default(function() return end),
            runargs = T:new({})
                :values(
                -- TODO add string[] as supported value
                  T:new(
                    T:new("string")
                    :map(function(key, val, path)
                      return {
                        value = val,
                        default = val,
                        complete = function(arglead, cmdline, cursorpos) return {} end,
                        check = function(value) return true end,
                        map = function(value) return value end
                      }
                    end),
                    T:new("boolean")
                    :map(function(key, val, path)
                      return {
                        value = val,
                        default = val,
                        complete = function(arglead, cmdline, cursorpos) return { "true", "false" } end,
                        check = function(value) return value == "true" or value == "false" or value == "" end,
                        map = function(value)
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
                      }
                    end),
                    T:new({
                      default = T:new(T:new("string"), T:new("boolean"), T:new("nil")):default(nil),
                      value = T:new(T:new("string"), T:new("boolean"), T:new("nil")):default(nil),
                      complete = T:new(T:new("function"), T:new("nil")):default(nil),
                      check = T:new(T:new("function"), T:new("nil")):default(nil),
                      map = T:new(T:new("function"), T:new("nil")):default(function(val) return val end)
                    })
                    :map(function(key, val, path)
                      val.value = val.default
                      if val.complete == nil then
                        if type(val.value) == "boolean" then
                          val.complete = function(arglead, cmdline, cursorpos) return { "true", "false" } end
                        elseif type(val.value) == "string" then
                          val.complete = function(arglead, cmdline, cursorpos) return {} end
                        end
                      end
                      if val.check == nil then
                        if type(val.value) == "boolean" then
                          val.check = function(value) return value == "true" or value == "false" or value == "" end
                        elseif type(val.value) == "string" then
                          val.check = function(value) return true end
                        end
                      end
                      return val
                    end),
                    T:new({}):values(T:new("string"))
                    :validate(function(key, val, path) return #val > 0 end)
                    :map(function(key, val, path)
                      return {
                        value = val[1],
                        default = val[1],
                        complete = function(arglead, cmdline, cursorpos) return val end,
                        check = function(value) return true end,
                        map = function(value) return value end
                      }
                    end)
                  )
                ),
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
        :map(function(key, val, path)
          if val.active_conf == nil then return next(val) end -- Only 1 language configuration
          return val
        end)
      )
      :default_values(require("runner.lang"))
})

return { config = config, schema = schema }
