return {
  default = function()
    local runnerFiles = {
      currFile = vim.api.nvim_buf_get_name(0),
      currFileDir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      currFileName = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    }
    return runnerFiles
  end,
  user= function()
  end,
  build = function(defaultFiles, userFiles)
    return ""
  end,
  run = function(defaultFiles, userFiles)
    return ""
  end,
  buildAndRun = function(placeHolders)
    return ""
  end
}
