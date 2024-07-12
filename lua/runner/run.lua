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
  local term = getActiveTerminalWinId()
  local currWin = vim.api.nvim_get_current_win()

  if term == nil then
    vim.cmd([[vsplit | terminal]] .. "\n")
    term = getActiveTerminalWinId()
  end

  runInTerminalById(term, cmd)
  vim.schedule(function() vim.api.nvim_set_current_win(currWin) end)
end

local function stopExecution()
  local term = getActiveTerminalWinId()
  local currWin = vim.api.nvim_get_current_win()
  if term then
    vim.api.nvim_set_current_win(term)
    vim.cmd("startinsert")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "n", false)
  end
  vim.schedule(function() vim.api.nvim_set_current_win(currWin) end)
end

local function runWithBufferConfig()
  local runnerFiles = vim.api.nvim_buf_get_var(0, "runnerFiles")
  local ft = vim.api.nvim_get_option_value("filetype", {})
  local config = require('runner.config')[ft]
  local cmd = config.buildAndrun(runnerFiles.defaultFiles, runnerFiles.userFiles)
  runInTerminal(cmd)
end

return {
  start = runWithBufferConfig,
  stop = stopExecution
}
