HLText = {}

function HLText:new(o)
    o = o
        or {
            _index = 0,
            _pos = 0,

            text = "",
            columns = {},
            groups = {},
        }
    setmetatable(o, { __index = HLText })
    return o
end

local function is_new_style(self, style)
    if self._index == 0 then
        return true
    end
    if vim.deep_equal(self.groups[self._index].val, style) then
        return false
    end
    return true
end

function HLText:add(part, text, style)
    local space = is_new_style(self, style)

    -- stack highlight group
    local group = "GitStat" .. string.upper(string.sub(part, 1, 1)) .. string.sub(part, 2)
    table.insert(self.groups, {
        group = group,
        val = style,
    })

    -- stack highlight positions
    local col_end = self._pos + #text + (space and 2 or 1)
    table.insert(self.columns, {
        group = group,
        col_start = self._pos,
        col_end = col_end,
    })

    -- stack part text
    if space then
        self.text = self.text .. " " .. text .. " "
    else
        self.text = self.text .. text .. " "
    end
    self._pos = col_end
    self._index = self._index + 1
end

return HLText
