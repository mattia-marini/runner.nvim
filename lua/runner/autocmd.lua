local function initBuffer()
  -- print(string.format('event fired: %s', vim.inspect(ev)))
  -- print("Detectato filetype ")

  local ft = vim.api.nvim_get_option_value("filetype", {})

  local globalConfig = require("runner.config")

  local dprint = require("runner.utils").dprint

  local ftConfig = globalConfig.lang[ft]

  if not ftConfig then
    local ignored_fts = {
      oil = true,
      cmp_menu = true,
    }
    if not ignored_fts[ft] then
      dprint(
        "[runner.nvim] The current filetype (" ..
        ft .. ") is not supported out of the box. Add the supported field in the config if you know what you are doing"
      )
    end
    return
  end

  local runnerArgs = {
    default = require("runner.args").new(),
    user = ftConfig.userArgs()
  }

  vim.api.nvim_buf_set_var(0, "runnerArgs", runnerArgs)

  vim.api.nvim_buf_create_user_command(0, "Runargs", function(args)
    local conf = vim.api.nvim_buf_get_var(0, "runnerArgs")
    conf.default.args = args.args
    vim.api.nvim_buf_set_var(0, "runnerArgs", conf)
  end, { nargs = "*" })

  if globalConfig.mappings then
    for key, val in pairs(globalConfig.mappings) do
      vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
    end
  end

  --P(ftConfig)
  for key, val in pairs(ftConfig.mappings) do
    vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = initBuffer
})
