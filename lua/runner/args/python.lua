---@type RunnerPythonArgs
local M = {}

---@class RunnerPythonArgs
---@field common RunnerCommonArgs Common args for all python projects
---@field venv PythonVenvArgs Args specific to venv projects
---@field single_file PythonSingleFile Args specific to single file python scripts

---@class PythonVenvArgs
---@field root fun(): string? The root of the current venv-based project

---@class PythonSingleFile
---@field root fun(): string? The root directory of the current single .py file

M.common = require("runner.args.common")

M.venv = {}
function M.venv.root()
  -- Looks for 'pyproject.toml', 'requirements.txt', or 'venv' directory
  return vim.fs.root(0, { "pyproject.toml", "requirements.txt", ".venv", "venv" })
end

M.single_file = {}
function M.single_file.root()
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

return M
