local single_file = {
  single_file = true,
  root = function() return vim.api.nvim_buf_get_name(0) end,
  runargs = { executable = "a.out", args = "" },
  ---@type fun(args: RunnerCArgs, runargs: table<string,table<string>>): string
  build_and_run = function(args, runargs)
    return "cd '" ..
        args.single_file.root() .. "' && clang " .. args.common.curr_file_name() .. " -o " .. runargs.executable.value ..
        " && " .. "./" .. runargs.executable.value .. " " .. runargs.args.value
  end
}


local make = {
  single_file = false,
  root = function() return vim.fs.root(0, "Makefile") end,
  runargs = { target = "ALL", args = "" },
  ---@type fun(args: RunnerCArgs, runargs: table<string,table<string>>): string
  build_and_run = function(args, runargs)
    return "cd '" .. args.make.root() .. "' && make " .. runargs.target.value .. " && ./" .. runargs.target.value
  end
}

local M = {}


M.single_file = single_file
M.make = make
M.active_conf = "single_file"

return M
