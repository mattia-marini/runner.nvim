local function path_from_root(root, path, module)
  local normalized_path = vim.fs.normalize(path)
  local normalized_root = vim.fs.normalize(root)

  local rv = normalized_path:sub(#normalized_root + 1)
  if module then
    rv = rv:gsub("%.py$", "")
    rv = rv:gsub("/$", "")
    rv = rv:gsub("^/", "")
    rv = rv:gsub("/", ".")
  else
    rv = rv:gsub("^/", "")
  end
  return rv
end

local single_file = {
  single_file = true,
  root = function() return vim.api.nvim_buf_get_name(0) end,
  runargs = { python = { "python", "python3" }, args = "" },
  ---@type fun(args: RunnerPythonArgs, runargs: table<string,table<string>>): string?
  build_and_run = function(args, runargs)
    return "cd " ..
        args.common.curr_file_dir() ..
        " && " .. runargs.python.value .. " " .. args.common.curr_file_name() .. " " .. runargs
        .args.value
  end
}


local venv = {
  single_file = false,
  root = function() return vim.fs.root(0, { "pyproject.toml", "requirements.txt", ".venv", "venv" }) end,
  ---@type table<string, RunargSpecifier>
  runargs = {
    python = { "python", "python3" },
    ["-m"] = true,
    args = "",
    entry_point = {
      complete = function(arglead, cmdline, cursorpos, second_arg)
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
    local m_flag_str = runargs["-m"].value == true and "-m" or ""
    return "cd " ..
        args.venv.root() .. " && " ..
        runargs.python.value .. " " ..
        m_flag_str .. " " ..
        runargs.entry_point.value
  end,
  init = function()
    vim.api.nvim_buf_create_user_command(0, "SetEntry", function(args)
      local active_config = require("runner.utils").get_curr_ft_active_config()
      if not active_config then return end
      print(vim.inspect(active_config.runargs))

      print(active_config.runargs["-m"].value == true)

      local relative_path = path_from_root(active_config.root(), vim.api.nvim_buf_get_name(0),
        active_config.runargs["-m"].value == true)
      vim.cmd(":Runargs entry_point " .. relative_path)
    end, {})
  end
}

local uv = {
  single_file = false,
  root = function() return vim.fs.root(0, { "pyproject.toml", "requirements.txt", ".venv", "venv" }) end,
  ---@type table<string, RunargSpecifier>
  runargs = {
    ["-m"] = true,
    args = "",
    entry_point = {
      complete = function(arglead, cmdline, cursorpos, second_arg)
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
    local m_flag_str = runargs["-m"].value == true and "-m" or ""
    return "cd " ..
        args.venv.root() .. " && uv run " ..
        m_flag_str .. " " ..
        runargs.entry_point.value
  end,
  init = function()
    vim.api.nvim_buf_create_user_command(0, "SetEntry", function(args)
      local active_config = require("runner.utils").get_curr_ft_active_config()
      if not active_config then return end

      local relative_path = path_from_root(active_config.root(), vim.api.nvim_buf_get_name(0),
        active_config.runargs["-m"].value == true)
      vim.cmd(":Runargs entry_point " .. relative_path)
    end, {})
  end
}

local M = {}


M.single_file = single_file
M.venv = venv
M.uv = uv
M.active_conf = "uv"

return M
