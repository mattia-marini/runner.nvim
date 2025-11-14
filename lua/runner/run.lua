local dprint = require("runner.utils").dprint

local function findTeminalWinIdForBuffer(buff)
  if buff == 0 then
    buff = vim.api.nvim_get_current_buf()
  end

  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    -- local termInfos = vim.api.nvim_win_get_var(win, "runnerTermInfos")
    local ok, termInfos = pcall(vim.api.nvim_win_get_var, win, "runnerTermInfos")
    if ok ~= nil and termInfos ~= nil and termInfos.initiator_buff == buff then
      return win, termInfos
    end
  end
  return nil
end

local function runInTerminal(cmd)
  local termInfos = findTeminalWinIdForBuffer(0)
  if (termInfos ~= nil) then
    vim.notify("A process is already running for this buffer", vim.log.levels.WARN)
    return
  end


  local initiator_buff = vim.api.nvim_get_current_buf();

  vim.cmd("vnew")
  local term_channel_id = vim.fn.termopen(cmd)

  vim.api.nvim_win_set_var(0, "runnerTermInfos", { initiator_buff = initiator_buff, ch = term_channel_id })
end

local function stopExecution()
  local term_win_id, term_infos = findTeminalWinIdForBuffer(0)
  if (term_win_id == nil or term_infos == nil) then
    vim.notify("No running process to stop", vim.log.levels.WARN)
    return
  end

  vim.fn.jobstop(term_infos.ch)
  vim.api.nvim_win_del_var(term_win_id, "runnerTermInfos")
  vim.api.nvim_buf_delete(vim.api.nvim_win_get_buf(term_win_id), { force = true })
  -- vim.api.nvim_win_close(term_win_id, true)
end

local function runWithBufferConfig()
  local runnerArgs = vim.api.nvim_buf_get_var(0, "runnerArgs")
  local ft = vim.api.nvim_get_option_value("filetype", {})
  local config = require('runner.config').lang[ft]

  local cmd = config.buildAndRun(runnerArgs)
  runInTerminal(cmd)
end


local function append(t1, t2)
  for k, v in ipairs(t2) do table.insert(t1, v) end
end

local open_kitty_window_pid = nil
local function run_kitty(cmd)
  local run_mode      = require("runner.utils").get_global_config().run_mode
  local opts          = run_mode.opts

  local run_cmd       = {}
  local close_wnd_cmd = {}

  -- print(vim.inspect(run_mode))
  if opts.custom ~= nil then
    close_wnd_cmd = opts.custom(cmd)
  else
    if open_kitty_window_pid ~= nil then
      append(close_wnd_cmd, {
        "kitten", "@", "close-window",
        "--ignore-no-match",
        "--match=id:" .. open_kitty_window_pid
      })
    end

    append(run_cmd, {
      "kitten", "@", "launch",
      "--title=" .. opts.title,
      "--type=" .. opts.type,
      "--cwd=" .. opts.cwd,
    })

    if opts.keep_focus then append(run_cmd, { "--keep-focus" }) end
    if opts.copy_env then append(run_cmd, { "--copy-env" }) end
    if opts.hold then append(run_cmd, { "--hold" }) end

    local other = opts.other
    if type(other) == "table" then
      for _, v in ipairs(other) do table.insert(run_cmd, v) end
    elseif type(other) == "string" then
      for flag in other:gmatch("%S+") do
        table.insert(run_cmd, flag)
      end
    end

    append(run_cmd, { opts.shell, "-c", cmd })
  end

  if open_kitty_window_pid ~= nil then
    local rv = vim.system(close_wnd_cmd, {})
  end

  vim.system(run_cmd, {},
    function(obj)
      if obj.code ~= 0 then
        dprint("Failed to run kitty cmd " .. obj.stderr)
        return
      else
        open_kitty_window_pid = tonumber(obj.stdout)
      end
    end)

  -- kitten @ launch --title=Email --type=tab --copy-env --hold --cwd=current fish -c "echo ciao && echo ciao2"
  -- kitten @ close-window --ignore-no-match --match=id:30
end

local function start()
  local ft_config = require("runner.utils").get_curr_ft_active_config()
  if not ft_config then
    dprint("No configuration found for current filetype", vim.log.levels.ERROR)
    return
  end

  local args = require("runner.args")[vim.api.nvim_get_option_value("filetype", {})]
  local runargs = ft_config.runargs

  local cmd = ft_config.build_and_run(args, runargs)

  -- local cmd = "echo hello from runner"
  print(cmd)
  run_kitty(cmd)
end

local function stop()
end

return {
  start = start,
  stop = stop
}
