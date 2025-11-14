local function init_buffer()
  -- print(string.format('event fired: %s', vim.inspect(ev)))
  -- print("Detectato filetype ")

  local utils = require("runner.utils")

  if utils.is_curr_ft_ignored() then return end
  if not utils.is_curr_ft_supported() then return end

  local active_ft_config = utils.get_curr_ft_active_config()
  local global_config = utils.get_global_config()

  vim.api.nvim_buf_create_user_command(0, "Runargs", function(args)
    local key = args.fargs[1]

    local runargs = utils.get_curr_runargs()
    if runargs == nil or runargs[key] == nil then
      utils.dprint("Invalid runarg key \"" .. key .. "\"", vim.log.levels.WARN)
      return
    end

    -- print("args.args:", args.args)
    local second_arg = args.args:match("^%s*%S+%s*(.-)%s*$")
    -- print("second arg:", second_arg)

    if runargs[key].check then
      if not runargs[key].check(second_arg) then
        utils.dprint("Invalid runarg value \"" .. second_arg .. "\" for key \"" .. key .. "\"", vim.log.levels.WARN)
        return
      end
    end



    local mapped_value
    if runargs[key].map then
      mapped_value = runargs[key].map(second_arg)
    else
      mapped_value = second_arg
    end

    runargs[key].value = mapped_value
  end, {
    nargs = "*",
    complete = function(arglead, cmdline, cursorpos)
      local runargs = utils.get_curr_ft_active_config().runargs
      local runarg_keys = {}
      for key, _ in pairs(runargs) do table.insert(runarg_keys, key) end
      local argv = vim.split(cmdline, "%s+")
      if #argv == 2 then
        return runarg_keys
      elseif #argv > 2 then
        local runarg_specifier = runargs[argv[2]]
        if runarg_specifier == nil then
          return {}
        end

        local second_arg = cmdline:match("^%s*%S+%s+%S+%s*(.-)%s*$")
        if runarg_specifier.complete then
          return runarg_specifier.complete(arglead, cmdline, cursorpos, second_arg)
        else
          return {}
        end
      end
    end
  })

  if global_config.mappings then
    for key, val in pairs(global_config.mappings) do
      vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
    end
  end

  --P(ftConfig)
  for key, val in pairs(active_ft_config.mappings) do
    vim.api.nvim_buf_set_keymap(0, "n", key, "", { callback = val })
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = init_buffer
})
