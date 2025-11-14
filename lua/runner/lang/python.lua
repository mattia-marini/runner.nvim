local single_file = {
  single_file = true,
  root = function() return vim.api.nvim_buf_get_name(0) end,
  runargs = { python = { "python", "python3" }, args = "" },
  ---@type fun(args: RunnerPythonArgs, runargs: table<string,table<string>>): string?
  build_and_run = function(args, runargs)
    return "cd " ..
        args.common.curr_file_dir .. " && " .. runargs.python .. " " .. args.common.curr_file_name .. " " .. runargs
        .args
  end
}


local x = 0
local venv = {
  single_file = false,
  root = function() return vim.fs.root(0, { "pyproject.toml", "requirements.txt", ".venv", "venv" }) end,
  ---@type table<string, RunargSpecifier>
  runargs = {
    python = { "python", "python3" },
    args = "",
    entry_point = {
      complete = function(arglead, cmdline, cursorpos, second_arg)
        print(arglead)
        local root = require("runner.args.python").venv.root()
        if not root then return {} end
        local curr_dir = vim.fs.joinpath(root, vim.fs.dirname(second_arg))
        local files = {}
        for name, type in vim.fs.dir(curr_dir) do
          local is_dir = type == "directory"
          local is_python_file = type == "file" and name:match("%.py$")
          if is_dir or is_python_file then
            table.insert(files, name)
          end
        end
        return files
      end
    }
  },
  ---@type fun(args: RunnerPythonArgs, runargs: table<string,table<string>>): string?
  build_and_run = function(args, runargs)
    if not runargs.entry_point.value then
      require("runner.utils").dprint("You should set an entry point (:Runargs entry_point <path>)")
      return
    end
    return "cd " .. args.venv.root() .. " && " .. runargs.python.value .. " " .. runargs.entry_point.value
  end
}

local M = {}


M.single_file = single_file
M.venv = venv
M.active_conf = "venv"

return M
