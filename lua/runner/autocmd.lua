local function init_buffer()
  -- print(string.format('event fired: %s', vim.inspect(ev)))
  -- print("Detectato filetype ")


  local dprint = require("runner.utils").dprint
  local ft = vim.api.nvim_get_option_value("filetype", {})
  local global_config = require("runner.config.config")[1]
  local ft_config = global_config.lang[ft]


  if not ft_config then
    if not global_config.ignored_fts[ft] then
      dprint(
        "[runner.nvim] The current filetype (" ..
        ft .. ") is not supported out of the box. Add the supported field in the config if you know what you are doing"
        , vim.log.levels.INFO)
    end
    return
  end


  -- vim.api.nvim_buf_create_user_command(0, "Runargs", function(args)
  --   local conf = vim.api.nvim_buf_get_var(0, "runnerArgs")
  --   conf.default.args = args.args
  --   vim.api.nvim_buf_set_var(0, "runnerArgs", conf)
  -- end, { nargs = "*" })

  if global_config.mappings then
    for key, val in pairs(global_config.mappings) do
      vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
    end
  end

  --P(ftConfig)
  for key, val in pairs(ft_config.mappings) do
    vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = init_buffer
})
