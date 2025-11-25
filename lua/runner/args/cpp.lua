---@type RunnerCppArgs
local M = {}

---@class RunnerCppArgs
---@field common RunnerCommonArgs Common args for all
---@field make CppMakeArgs Args specific to Make projects
---@field cmake CppCMakeArgs Args specific to CMake projects
---@field single_file CppSingleFile Args specific to single file projects

---@class CppMakeArgs
---@field root fun(): string? The root of the current make project

---@class CppCMakeArgs
---@field root fun(): string? The root of the current cmake project

---@class CppSingleFile
---@field root fun(): string? The root of the current single file project

M.common = require("runner.args.common")

M.make = {}
function M.make.root() return vim.fs.root(0, "Makefile") end

M.cmake = {}
function M.cmake.root() return vim.fs.root(0, "CMakeLists.txt") end

M.single_file = {}
function M.single_file.root() return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) end

return M
