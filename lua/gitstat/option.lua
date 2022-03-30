local M = {}

local default_parts = {
    "branch",
    "remote",
    "ahead",
    "behind",
    "recruit",
    "unmerged",
    "staged",
    "unstaged",
    "untracked",
}

local default_prefix = {
    branch = "\u{F418} ", --  .
    remote = "\u{F427} ", --  .
    ahead = "\u{F55D} ", --  .
    behind = "\u{F545} ", --  .
    recruit = "\u{F6C8} ", --  .
    unmerged = "\u{FBC2} ", -- ﯂ .
    staged = "\u{F00C} ", --  .
    unstaged = "\u{F067} ", --  .
    untracked = "\u{F12A} ", --  .
}

M.get_prefix = function(part)
    local opt = vim.g["gitstat#prefix#" .. part]
    if opt == nil then
        return default_prefix[part]
    end
    return opt
end

M.get_parts = function()
    local opt = vim.g["gitstat#parts"]
    if opt == nil then
        return default_parts
    end
    return vim.fn.split(opt, ",")
end

local default_blend = 40
M.get_blend = function()
    local opt = vim.g["gitstat#blend"]
    if opt == nil then
        return default_blend
    end
    return opt
end

M.default_prefix = default_prefix

return M
