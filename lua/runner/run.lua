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


local function start()
  local ft_config = require("runner.utils").get_curr_ft_active_config()
  if not ft_config then
    dprint("No configuration found for current filetype", vim.log.levels.ERROR)
    return
  end

  local args = require("runner.args")[vim.api.nvim_get_option_value("filetype", {})]
  local runargs = ft_config.runargs

  local cmd = ft_config.build_and_run(args, runargs)

  print(cmd)
end

local function stop()
end

return {
  start = start,
  stop = stop
}
