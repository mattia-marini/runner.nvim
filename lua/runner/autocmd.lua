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
    local value

    local runargs = require("runner.utils").get_curr_ft_active_config().runargs
    if runargs[key] == nil then
      dprint("Invalid runarg key: " .. key, vim.log.levels.ERROR)
      return
    end

    local second_arg = args.args:match("^%s*%S+%s+%S+%s*(.-)%s*$")
    print("second arg:", second_arg)
    if #args.fargs == 2 then
      value = true
    elseif second_arg == "true" then
      value = true
    elseif second_arg == "false" then
      value = false
    end


    -- string
    -- boolean 
    -- string []
    -- table

    for i = 2, #args.args do
    end


    if type(runargs[key]) == "string" then
      value = args.fargs[2]
    elseif type(runargs[key]) == "boolean" then
    end

    for i = 2, #args.fargs do
      if i > 2 then value = value .. " " end
      value = value .. args.fargs[i]
    end

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
        if type(runarg_specifier) == "string" then
          return {}
        elseif type(runarg_specifier) == "boolean" then
          return { "true", "false" }
        elseif type(runarg_specifier) == "table" and runarg_specifier.value == nil then
          return runarg_specifier
        elseif type(runarg_specifier) == "table" and runarg_specifier.value ~= nil then
          if runarg_specifier.complete ~= nil then
            return runarg_specifier.complete(arglead, cmdline, cursorpos)
          end
        end
        return {}
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
