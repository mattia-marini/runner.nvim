local function init_buffer()
  -- print(string.format('event fired: %s', vim.inspect(ev)))
  -- print("Detectato filetype ")


  local utils = require("runner.utils")
  local dprint = utils.dprint
  local ft = vim.api.nvim_get_option_value("filetype", {})
  local global_config = require("runner.config.config")[1]
  local active_ft_config = utils.get_curr_ft_active_config()


  if not active_ft_config then
    if not global_config.ignored_fts[ft] then
      dprint(
        "[runner.nvim] The current filetype (" ..
        ft .. ") is not supported out of the box. Add the supported field in the config if you know what you are doing"
        , vim.log.levels.INFO)
    end
    return
  end


  vim.api.nvim_buf_create_user_command(0, "Runargs", function(args)
    local key = args.fargs[1]

    local runargs = require("runner.args.runargs").get()
    if runargs == nil or runargs[key] == nil then
      dprint("Invalid runarg key \"" .. key .. "\"", vim.log.levels.ERROR)
      return
    end

    local second_arg = args.args:match("^%s*%S+%s+%S+%s*(.-)%s*$")
    print("second arg:", second_arg)

    if not runargs[key].check(second_arg) then
      dprint("Invalid runarg value \"" .. second_arg .. "\" for key \"" .. key .. "\"", vim.log.levels.ERROR)
      return
    end
    runargs[key].map(second_arg)
    runargs[key].value = runargs[key].map(second_arg)
    -- local conf = vim.api.nvim_buf_get_var(0, "runnerArgs")
    -- conf.default.args = args.args
    -- vim.api.nvim_buf_set_var(0, "runnerArgs", conf)
  end, {
    nargs = "*",
    complete = function(arglead, cmdline, cursorpos)
      local runargs = require("runner.utils").get_curr_ft_active_config().runargs
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
        -- Parsed config alway has ComplexRunargSpecifier as value
        return runarg_specifier.complete(arglead, cmdline, cursorpos)
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
