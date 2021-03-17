local global = require('gitstat.global')

local function hide()
  local w = global.get_window()
  if w then
    pcall(vim.api.nvim_win_close, w, true)
    global.del_window()
  end
  local b = global.get_buffer()
  if b then
    pcall(vim.api.nvim_buf_delete, b)
    global.del_buffer()
  end
end

function get_git_stat(path)
  local res = vim.fn.system("git -C '" .. path .. "' status --porcelain --branch --ahead-behind --untracked-files --renames")
  if string.sub(res, 1, 7) == 'fatal: ' then
    return nil
  end
  local info = { ahead = 0, behind = 0, sync = '', unmerged = 0, untracked = 0, staged = 0, unstaged = 0 }
  local file
  for _, file in next, vim.fn.split(res, "\n") do
    local staged = string.sub(file, 1, 1)
    local unstaged = string.sub(file, 2, 2)
    local changed = string.sub(file, 1, 2)
    if changed == '##' then
      -- ブランチ名を取得する
      local words = vim.fn.split(file, '\\.\\.\\.\\|[ \\[\\],]')
      if #words == 2 then
        info.local_branch = words[2] .. '?'
        info.sync = "\u{F12A}"
      else
        info.local_branch = words[2]
        info.remote_branch = words[3]
        if #words > 3 then
          local key = ''
          local i = ''
          local r = ''
          for i, r in ipairs(words) do
            if i > 3 then
              if key ~= '' then
                info[key] = r
                key = ''
              else
                key = r
              end
            end
          end
        end
      end
    elseif staged == 'U' or unstaged == 'U' or changed == 'AA' or changed == 'DD' then
      info.unmerged = info.unmerged + 1
    elseif changed == '??'  then
      info.untracked = info.untracked + 1
    else
      if staged ~= ' ' then
        info.staged = info.staged + 1
      end
      if unstaged ~= ' ' then
        info.unstaged = info.unstaged + 1
      end
    end
  end
  return info
end

local get_git_stat_string = function ()
  local location = vim.fn.getcwd()
  local stat = get_git_stat(location)
  if stat == nil then
    return ''
  end
  local function withPrefix(prefix, value)
    if not value or value == 0 then
      return ''
    end
    return prefix .. ' ' .. value
  end
  local output = vim.fn.trim(vim.fn.join(vim.tbl_filter(function(w)
    return w ~= nil and w ~= ''
  end, {
    withPrefix("\u{FF55D}", stat.ahead),     -- 󿕝 .
    withPrefix("\u{FF545}", stat.behind),    -- 󿕅 .
    stat.sync,
    withPrefix('\u{FFBC2}', stat.unmerged),  -- 󿯂 .
    withPrefix("\u{FF62B}", stat.staged),    -- 󿘫 .
    withPrefix("\u{FF914}", stat.unstaged),  -- 󿤔 .
    withPrefix("\u{FF7D5}", stat.untracked), -- 󿟕 .
  })))
  if output == '' then
    return output
  else
    return ' ' .. output .. ' '
  end
end

local function get_git_stat_profile()
  local stat = get_git_stat_string()

  local width = vim.fn.strdisplaywidth(stat)

  return {
    stat = stat,
    row = 0,
    col = vim.api.nvim_get_option('columns') - width,
    width = width,
    height = 1,
  }
end

local function update()
  local b = global.get_buffer()
  if not b then
    return
  end
  local w = global.get_window()
  if not w then
    return
  end
  local profile = get_git_stat_profile()
  vim.api.nvim_buf_set_lines(b, 0, 1, true, {profile.stat})
  vim.api.nvim_win_set_config(w, {
    relative = 'editor',
    row = profile.row,
    col = profile.col,
    width = profile.width,
    height = profile.height,
  })
end

local function show()
  local b = global.get_buffer()
  if not b then
    b = vim.api.nvim_create_buf(false, true)
    global.put_buffer(b)
  end
  local w = global.get_window()
  if not w then
    w = vim.api.nvim_open_win(b, false, {
      relative = 'editor',
      row = 0,
      col = 1,
      width = 1,
      height = 1,
      focusable = false,
      style = 'minimal',
    })
    vim.api.nvim_win_set_option(w, 'winhighlight', 'Normal:GitStatWindow,NormalNC:GitStatWindow')
    vim.api.nvim_win_set_option(w, 'winblend', 40)
    global.put_window(w)
  end
  vim.api.nvim_win_set_buf(w, b)
  update()
end

local function stop_sync()
  global.put_sync(false)
end

local delay = 3000
local function sync()
  update()
  if global.get_sync() then
    vim.defer_fn(vim.schedule_wrap(sync), delay)
  end
end

local function start_sync()
  global.put_sync(true)
  vim.defer_fn(vim.schedule_wrap(sync), delay)
end

return {
  show = show,
  hide = hide,
  update = update,
  start_sync = start_sync,
  stop_sync = stop_sync,
}
