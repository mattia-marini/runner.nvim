local M = {}
local cargo = {
  single_file = false,
  root = function() return vim.api.nvim_buf_get_name(0) end,
  runargs = { args = "" },
  ---@type fun(args: RunnerRustArgs, runargs: table<string,table<string>>): string
  build_and_run = function(args, runargs)
    return "cd '" .. args.cargo.root() .. "' && cargo run -- " .. runargs.args.value
  end
}

M.cargo = cargo
M.active_conf = "cargo"

return M
