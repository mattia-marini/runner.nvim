local singleFile = require("lua.runner.defaults.config.common").new()
local make = require("lua.runner.defaults.config.common").new()

singleFile.singleFile = true
singleFile.root = function() return vim.api.nvim_buf_get_name(0) end
singleFile.runargs = { executable = "a.out", args = "" }
singleFile.buildAndRun = function()
  local args = require("lua.runner.defaults.args.c")
  return "cd " .. args.singleFile.root() .. " && clang " .. args.common.currFileName() .. " -o " .. args.common.runargs()
end


make.singleFile = false
make.root = function() return vim.fs.root(0, "Makefile") end
make.runargs = { target = "all", args = "" }
make.buildAndRun = function()
  local args = require("lua.runner.defaults.args.c")
  return "cd " .. args.make.root() .. " && make " .. make.runargs.target .. " && ./" .. make.runargs.target
end


local M = {}

M.singleFile = singleFile
M.make = singleFile
M.activeConf = "singleFile"

return M
