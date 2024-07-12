local function initBuffer()
  -- print(string.format('event fired: %s', vim.inspect(ev)))
  --print("Detectato filetype ")

  local ft = vim.api.nvim_get_option_value("filetype", {})

  local globalConfig = require("runner.config")
  local ftConfig = globalConfig[ft]

  if not ftConfig then return end -- If a language is not setup do nothing

  vim.api.nvim_buf_set_var(0, "runnerFiles",
    { defaultFiles = ftConfig.defaultFiles(), userFiles = ftConfig.userFiles() })

  --P(vim.api.nvim_buf_get_var(0, "runnerFiles"))

  --P(globalConfig)
  if globalConfig.mappings then
    for key, val in pairs(globalConfig.mappings) do
      vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
    end
  end

  --P(ftConfig)
  if ftConfig.mappings then
    for key, val in pairs(ftConfig.mappings) do
      vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
    end
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  --pattern = { "*.c", "*.h" },
  callback = initBuffer
})
