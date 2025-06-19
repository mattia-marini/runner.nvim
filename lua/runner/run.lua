vim.api.nvim_buf_set_var(0, "runnerTermInfos", nil);

local function getActiveTerminalWinId()
  local wins = vim.api.nvim_list_wins()
  local curr_tab = vim.api.nvim_get_current_tabpage()

  for _, win in ipairs(wins) do
    local infos = vim.fn.getwininfo(win)[1]
    if infos.terminal == 1 and infos.tabnr == curr_tab then
      return win
    end
  end
  return nil
end

local function runInTerminalById(winid, cmd)
  vim.api.nvim_set_current_win(winid)
  vim.cmd("startinsert")
  vim.api.nvim_feedkeys(cmd .. "\n", "", true)
end

local function runInTerminal(cmd)
  local termInfos = vim.api.nvim_buf_get_var(0, "runnerTermInfos")
  if (termInfos ~= nil) then
    vim.notify("A process is already running in this buffer", vim.log.levels.WARN)
    return
  end

  local channel_id = termInfos.ch

  local text_file_buff = vim.api.nvim_get_current_buf();
  vim.cmd("vnew")
  local term_window = vim.api.nvim_get_current_win();

  local new_channel_id = vim.fn.termopen(cmd)
  vim.api.nvim_buf_set_var(text_file_buff, "runnerTermInfos", { ch = new_channel_id, win = term_window })
end

local function stopExecution()
  local termInfos = vim.api.nvim_buf_get_var(0, "runnerTermInfos")
  if (termInfos == nil) then
    vim.notify("No running process to stop", vim.log.levels.WARN)
    return
  end

  local channel_id = termInfos.ch
  local term_win = termInfos.win

  -- vim.api.nvim_chan_send(vim.api.nvim_buf_get_var(0, "runnerTermInfos"),
  --   vim.api.nvim_replace_termcodes("<C-c>", true, false, true))
  vim.fn.jobstop(channel_id)
  vim.api.nvim_buf_set_var(0, "runnerTermInfos", nil);
  vim.api.nvim_win_close(term_win, false)
  --   local term = getActiveTerminalWinId()
  --
  --   local currWin = vim.api.nvim_get_current_win()
  --
  --
  --   if term then
  --     vim.api.nvim_set_current_win(term)
  --     vim.cmd("startinsert")
  --     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "n", false)
  --   end
  --   vim.schedule(function() vim.api.nvim_set_current_win(currWin) end)
end

local function runWithBufferConfig()
  local runnerArgs = vim.api.nvim_buf_get_var(0, "runnerArgs")
  local ft = vim.api.nvim_get_option_value("filetype", {})
  local config = require('runner.config').lang[ft]

  -- P(config)

  --print("Runner args: ")
  --P(runnerArgs)

  local cmd = config.buildAndRun(runnerArgs)
  runInTerminal(cmd)
end

return {
  start = runWithBufferConfig,
  stop = stopExecution
}
