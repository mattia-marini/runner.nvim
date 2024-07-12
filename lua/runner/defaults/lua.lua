return {
  defaultFiles = function()
    local runnerFiles = {
      mainFile = vim.api.nvim_buf_get_name(0),
      mainFileDir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      mainFileName = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    }
    return runnerFiles
  end,
  userFiles = function()
  end,
   build = function(defaultFiles, userFiles)
    return "clang++ " .. defaultFiles.mainFile
  end,
  run = function(defaultFiles, userFiles)
    return "./a.out"
  end,
  buildAndrun = function(defaultFiles, userFiles)
    return "cd " .. defaultFiles.mainFileDir .. " && lua " .. defaultFiles.mainFileName
  end
}
