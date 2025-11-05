---@class RunnerArgs
---@field default DefaultRunnerArgs
---@field user table User-defined arguments


---@class DefaultRunnerArgs
---@field currFile fun():string Current file path
---@field currFileDir fun():string Current file directory
---@field currFileName fun():string Current file name
---@field root fun():string? The root of the current project
---@field args string Additional user-provided arguments, set with :Runargs

return {
  ---@return DefaultRunnerArgs
  new = function()
    return {
      currFile = function() return vim.api.nvim_buf_get_name(0) end,
      currFileDir = function() return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) end,
      currFileName = function() return vim.fs.basename(vim.api.nvim_buf_get_name(0)) end,
      root = function() return nil end,
      args = ""
    }
  end
}
