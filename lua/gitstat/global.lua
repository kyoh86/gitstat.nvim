local M = {}

M.get_namespace = function()
  return vim.g['gitstat#_namespace']
end

M.put_namespace = function(n)
  vim.g['gitstat#_namespace'] = n
end

M.get_window = function()
  local w = vim.g['gitstat#_window']
  if w and vim.api.nvim_win_is_valid(w) then
    return w
  end
  return nil
end

M.put_window = function(w)
  vim.g['gitstat#_window'] = w
end

M.del_window = function()
  vim.g['gitstat#_window'] = nil
end

M.get_buffer = function()
  return vim.g['gitstat#_buffer']
end

M.put_buffer = function(w)
  vim.g['gitstat#_buffer'] = w
end

M.del_buffer = function()
  vim.g['gitstat#_buffer'] = nil
end

M.get_sync = function()
  return vim.g['gitstat#_sync']
end

M.put_sync = function(e)
  vim.g['gitstat#_sync'] = e
end

M.del_sync = function()
  vim.g['gitstat#_sync'] = nil
end

return M
