---@class DefaultArgs
return {
  currFile = vim.api.nvim_buf_get_name(0),
  currFileDir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  currFileName = vim.fs.basename(vim.api.nvim_buf_get_name(0)),
  args = ""
}
