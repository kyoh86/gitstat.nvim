local M = {}

M.get_window = function()
  return vim.g['gitstat#_window']
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
