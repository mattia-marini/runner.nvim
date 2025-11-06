local singleFile = require("runner.defaults.config.common").new()
local make = require("runner.defaults.config.common").new()

singleFile.singleFile = true
singleFile.root = function() return vim.api.nvim_buf_get_name(0) end
singleFile.runargs = { executable = "a.out", args = "" }
singleFile.buildAndRun = function()
  local args = require("runner.defaults.args.c")
  return "cd " .. args.singleFile.root() .. " && clang " .. args.common.currFileName() .. " -o " .. args.common.runargs()
end


make.singleFile = false
make.root = function() return vim.fs.root(0, "Makefile") end
make.runargs = { target = "ALL", args = "" }
make.buildAndRun = function()
  local args = require("runner.defaults.args.c")
  return "cd " .. args.make.root() .. " && make " .. make.runargs.target .. " && ./" .. make.runargs.target
end


local M = {}

M.single_file = singleFile
M.make = singleFile
M.active_conf = "single_file"

return M
