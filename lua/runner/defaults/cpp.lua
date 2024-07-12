local conf = require("runner.defaults.common")

return {
  defaultFiles = function()
    local runnerFiles = {
      currFile = vim.api.nvim_buf_get_name(0),
      currFileDir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      currFileName = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    }
    return runnerFiles
  end,
  userFiles = function()
  end,
  build = function(defaultFiles, userFiles)
    return "clang++ " .. defaultFiles.currFile
  end,
  run = function(defaultFiles, userFiles)
    return "./a.out"
  end,
  buildAndRun = function(placeHolders)
    return "cd " ..
        placeHolders.default.currFileDir .. " && clang++ " .. placeHolders.default.currFileName .. " && ./a.out"
  end,
}
