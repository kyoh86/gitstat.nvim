local global = require('gitstat.global')
local option = require('gitstat.option')

local function init()
  local ns = global.get_namespace()
  if ns == nil then
    global.put_namespace(vim.api.nvim_create_namespace('gitstat'))
  end
end

local function hide()
  init()
  local w = global.get_window()
  if w then
    pcall(vim.api.nvim_win_close, w, true)
    global.del_window()
  end
  local b = global.get_buffer()
  if b then
    pcall(vim.api.nvim_buf_delete, b, {force = true})
    global.del_buffer()
  end
end

function get_git_stat(path)
  local res = vim.fn.system("git -C '" .. path .. "' status --porcelain --branch --ahead-behind --untracked-files --renames")
  local info = { ahead = 0, behind = 0, sync = false, unmerged = 0, untracked = 0, staged = 0, unstaged = 0 }
  if string.sub(res, 1, 7) == 'fatal: ' then
    return info
  end
  local file
  for _, file in next, vim.fn.split(res, "\n") do
    local staged = string.sub(file, 1, 1)
    local unstaged = string.sub(file, 2, 2)
    local changed = string.sub(file, 1, 2)
    if changed == '##' then
      -- ブランチ名を取得する
      local words = vim.fn.split(file, '\\.\\.\\.\\|[ \\[\\],]')
      if #words == 2 then
        info.branch = words[2] .. '?'
        info.sync = true -- "\u{F12A}"
      else
        info.branch = words[2]
        info.remote = words[3]
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

local function get_git_stat_profile()
  local location = vim.fn.getcwd()
  local stat = get_git_stat(location)

  local cols = 1
  local highs = {}
  local texts = {}
  for _, key in ipairs(option.get_parts()) do
    local value = stat[key]
    if not value or value == 0 then
      goto continue
    end
    local text = option.get_prefix(key)
    if value == true then
      if not text or text == '' then
        goto continue
      end
    else
      text = text .. value
    end
    local group = 'GitStat' .. string.upper(string.sub(key, 1, 1)) .. string.sub(key, 2)
    local width = #text
    table.insert(highs, {
      group = group,
      col_start = cols,
      col_end = cols + width,
    })
    table.insert(texts, text)
    cols = cols + width + 1 -- 1 = space(join)
    ::continue::
  end

  local text = vim.fn.trim(vim.fn.join(texts))
  if text ~= '' then
    text = ' ' .. text .. ' '
  end
  local width = vim.fn.strdisplaywidth(text)
  return {
    text = text,
    highlights = highs,
    row = 0,
    col = vim.api.nvim_get_option('columns') - width,
    width = width,
    height = 1,
  }
end

local function update()
  init()
  local b = global.get_buffer()
  if not b then
    return
  end
  local w = global.get_window()
  if not w then
    return
  end
  vim.api.nvim_buf_clear_namespace(b, global.get_namespace(), 0, -1)
  local profile = get_git_stat_profile()
  vim.api.nvim_buf_set_lines(b, 0, 1, true, {profile.text})
  for _, hi in ipairs(profile.highlights) do
    vim.api.nvim_buf_add_highlight(b, global.get_namespace(), hi.group, 0, hi.col_start, hi.col_end)
  end
  if profile.text == '' or profile.width == 0 then
    vim.api.nvim_win_set_option(w, 'winblend', 100)
    vim.api.nvim_win_set_config(w, {
      relative = 'editor',
      row = profile.row,
      col = profile.col,
      width = 1,
      height = profile.height,
    })
  else
    vim.api.nvim_win_set_option(w, 'winblend', option.get_blend())
    vim.api.nvim_win_set_config(w, {
      relative = 'editor',
      row = profile.row,
      col = profile.col,
      width = profile.width,
      height = profile.height,
    })
  end
end

local function show()
  init()
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
    global.put_window(w)
  end
  vim.api.nvim_win_set_buf(w, b)
  update()
end

local function stop_sync()
  init()
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
  init()
  global.put_sync(true)
  vim.defer_fn(vim.schedule_wrap(sync), delay)
end

return {
  init = init,
  show = show,
  hide = hide,
  update = update,
  start_sync = start_sync,
  stop_sync = stop_sync,
}
