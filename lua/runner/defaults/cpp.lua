return {
  defaultFiles = function()
    local runnerFiles = {
      mainFile = vim.api.nvim_buf_get_name(0)
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
    return "clang++ " .. defaultFiles.mainFile .. " && ./a.out"
  end,
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop
  }
}
