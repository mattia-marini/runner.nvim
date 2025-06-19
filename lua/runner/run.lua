vim.api.nvim_buf_set_var(0, "runnerTermChannelId", nil);

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
  vim.cmd("vnew")
  local channel_id = vim.fn.jobstart(cmd, { term = true })
  vim.api.nvim_buf_set_var(0, "runnerTermChannelId", channel_id)
end

local function stopExecution()
  vim.api.nvim_chan_send(vim.api.nvim_buf_get_var(0, "runnerTermChannelId"),
    vim.api.nvim_replace_termcodes("<C-c>", true, false, true))
  vim.api.nvim_buf_set_var(0, "runnerTermChannelId", nil);
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
