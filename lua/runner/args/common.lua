---@type RunnerCommonArgs
local M = {}

---@class RunnerCommonArgs
---@field curr_file fun(): string Current file path
---@field curr_file_dir fun(): string Current file dirname
---@field curr_file_name fun(): string Current file basename

local utils = require("runner.utils")

function M.curr_file() return vim.api.nvim_buf_get_name(0) end

function M.curr_file_dir() return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) end

function M.curr_file_name() return vim.fs.basename(vim.api.nvim_buf_get_name(0)) end

return M
