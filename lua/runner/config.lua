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



return M, schema
