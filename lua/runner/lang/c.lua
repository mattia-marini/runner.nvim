local single_file = require("runner.lang.common").new()
local make = require("runner.lang.common").new()

single_file.single_file = true
single_file.root = function() return vim.api.nvim_buf_get_name(0) end
single_file.runargs = { executable = "a.out", args = "" }
single_file.build_and_run = function()
  local args = require("runner.args.c")
  return "cd " ..
      args.single_file.root() .. " && clang " .. args.common.curr_file_name() .. " -o " .. args.common.runargs()
end


make.single_file = false
make.root = function() return vim.fs.root(0, "Makefile") end
make.runargs = { target = "ALL", args = "" }
make.build_and_run = function()
  local args = require("runner.args.c")
  return "cd " .. args.make.root() .. " && make " .. make.runargs.target .. " && ./" .. make.runargs.target
end


local M = {}

M.single_file = single_file
M.make = make
M.active_conf = "single_file"

return M
