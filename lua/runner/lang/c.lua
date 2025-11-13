local single_file_ext = {
  single_file = true,
  root = function() return vim.api.nvim_buf_get_name(0) end,
  ---@class RunnerSingleFileRunargs
  runargs = { executable = "a.out", args = "" },
  ---@type fun(args: RunnerCArgs, runargs: RunnerSingleFileRunargs): string
  build_and_run = function(args, runargs)
    return "cd " ..
        args.single_file.root() .. " && clang " .. args.common.curr_file_name() .. " -o " .. runargs.executable
  end
}


local make_ext = {
  single_file = false,
  root = function() return vim.fs.root(0, "Makefile") end,
  ---@class RunnerMakeRunargs
  runargs = { target = "ALL", args = "" },
  ---@type fun(args: RunnerCArgs, runargs: RunnerMakeRunargs): string
  build_and_run = function(args, runargs)
    return "cd " .. args.make.root() .. " && make " .. runargs.target .. " && ./" .. runargs.target
  end
}

local M = {}


M.single_file = single_file_ext
M.make = make_ext
M.active_conf = "single_file"

return M
