---@type RunnerRustArgs
local M = {}

---@class RunnerRustArgs
---@field common RunnerCommonArgs Common args for all
---@field cargo RunnerCargoArgs Args specific to Cargo projects

---@class RunnerCargoArgs
---@field root fun(): string? The root of the current Cargo project

M.common = require("runner.args.common")

M.cargo = {}
function M.cargo.root() return vim.fs.root(0, { "Cargo.toml", "Cargo.lock", ".git" }) end

return M
