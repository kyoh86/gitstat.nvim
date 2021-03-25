local M = {}

local default_parts = {
  "branch",
  "remote",
  "ahead",
  "behind",
  "sync",
  "unmerged",
  "staged",
  "unstaged",
  "untracked",
}

local default_prefix = {
  branch = "\u{F418} ",     --  .
  remote = "\u{F427} ",     --  .
  ahead = "\u{FF55D} ",     -- 󿕝 .
  behind = "\u{FF545} ",    -- 󿕅 .
  sync = "\u{F12A} ",       --  .
  unmerged = "\u{FFBC2} ",  -- 󿯂 .
  staged = "\u{FF62B} ",    -- 󿘫 .
  unstaged = "\u{FF914} ",  -- 󿤔 .
  untracked = "\u{FF7D5} ", -- 󿟕 .
}

M.get_prefix = function(part)
  local opt = vim.g['gitstat#prefix#' .. part]
  if opt == nil then
    return default_prefix[part]
  end
  return opt
end

M.get_parts = function()
  local opt = vim.g['gitstat#parts']
  if opt == nil then
    return default_parts
  end
  return vim.fn.split(opt, ',')
end

local default_blend = 40
M.get_blend = function()
  local opt = vim.g['gitstat#blend']
  if opt == nil then
    return default_blend
  end
  return opt
end

M.default_prefix = default_prefix

return M
