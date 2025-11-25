local maven = {
  single_file = false,
  root = function()
    return require("runner.args.java").maven.root()
  end,
  ---@type table<string, RunargSpecifier>
  runargs = {
    args = "",
    clean = false,
    compile = true,
    ["-q"] = true,
  },
  ---@type fun(args: RunnerJavaArgs, runargs: table<string,table<string>>): string?
  build_and_run = function(args, runargs)
    local q_flag_str = runargs["-q"].value and "-q" or ""
    local compile_flag_str = runargs.compile.value and "compile" or ""
    local clean_flag_str = runargs.clean.value and "clean" or ""

    return "cd '" .. args.maven.root() .. "' && mvn " .. q_flag_str .. " " ..
        clean_flag_str .. " " .. compile_flag_str .. " " ..
        "exec:java " .. runargs.args.value
  end
}

local M = {}


M.maven = maven
M.active_conf = "maven"

return M
