local M = {}

local v = {}

function M.set(key, value)
    v[key] = value
end

function M.get(key)
    return v[key]
end

return M
