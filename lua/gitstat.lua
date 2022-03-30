local G = {
    state = nil,
    window = nil,
    buffer = nil,
    sync = nil,
    namespace = nil,
}

local O = {}

local M = {}

function M.hide()
    print("hide gitstat")
    state = nil
    if G.buffer then
        pcall(vim.api.nvim_buf_delete, G.buffer, { force = true })
        G.buffer = nil
    end
    if G.window then
        pcall(vim.api.nvim_win_close, G.window, true)
        G.window = nil
    end
end

local function get_git_stat(path)
    local res = vim.fn.system(
        "git -C '" .. path .. "' status --porcelain --branch --ahead-behind --untracked-files --renames"
    )
    local info = { ahead = 0, behind = 0, recruit = false, unmerged = 0, untracked = 0, staged = 0, unstaged = 0 }
    if string.sub(res, 1, 7) == "fatal: " then
        return info
    end
    for _, file in next, vim.fn.split(res, "\n") do
        local staged = string.sub(file, 1, 1)
        local unstaged = string.sub(file, 2, 2)
        local changed = string.sub(file, 1, 2)
        if changed == "##" then
            -- ブランチ名を取得する
            local words = vim.fn.split(file, "\\.\\.\\.\\|[ \\[\\],]")
            if #words == 2 then
                info.branch = words[2] .. "?"
                info.recruit = true
            else
                info.branch = words[2]
                info.remote = words[3]
                if #words > 3 then
                    local key = ""
                    for i, r in ipairs(words) do
                        if i > 3 then
                            if key ~= "" then
                                info[key] = r
                                key = ""
                            else
                                key = r
                            end
                        end
                    end
                end
            end
        elseif staged == "U" or unstaged == "U" or changed == "AA" or changed == "DD" then
            info.unmerged = info.unmerged + 1
        elseif changed == "??" then
            info.untracked = info.untracked + 1
        else
            if staged ~= " " then
                info.staged = info.staged + 1
            end
            if unstaged ~= " " then
                info.unstaged = info.unstaged + 1
            end
        end
    end
    return info
end

local function get_git_stat_profile()
    local location = vim.fn.getcwd()
    local stat = get_git_stat(location)

    local hl = require("gitstat.hltext"):new()
    for _, part in ipairs(O.parts) do
        local value = stat[part]
        local style = O.style[part]
        local t = type(value)
        if t == "nil" then
            -- noop
        elseif t == "boolean" then
            if value then
                hl:add(part, O.prefix[part], style)
            end
        elseif t == "string" then
            hl:add(part, O.prefix[part] .. value, style)
        elseif t == "number" then
            if value ~= 0 then
                hl:add(part, string.format("%s%d", O.prefix[part], value), style)
            end
        end
    end

    local width = vim.fn.strdisplaywidth(hl.text)
    return {
        text = hl.text,
        groups = hl.groups,
        columns = hl.columns,
        row = 0,
        col = vim.api.nvim_get_option("columns") - width,
        width = width,
        height = 1,
    }
end

function M.update()
    if G.state ~= "shown" then
        return
    end

    local b = G.buffer
    if not b then
        b = vim.api.nvim_create_buf(false, true)
        local group = vim.api.nvim_create_augroup("gitstat-buffer", { clear = false })
        vim.api.nvim_create_autocmd("WinClosed", {
            group = group,
            buffer = b,
            callback = M.revive,
        })
        G.buffer = b
        vim.bo[b].filetype = "gitstat"
    end
    local w = G.window
    if not w then
        w = vim.api.nvim_open_win(b, false, {
            relative = "editor",
            row = 0,
            col = 1,
            width = 1,
            height = 1,
            focusable = false,
            style = "minimal",
        })
        G.window = w
    end
    vim.api.nvim_win_set_buf(w, b)

    -- vim.api.nvim_buf_clear_namespace(b, G.namespace, 0, -1)

    local profile = get_git_stat_profile()
    vim.api.nvim_buf_set_lines(b, 0, 1, true, { profile.text })
    for _, hi in ipairs(profile.columns) do
        vim.api.nvim_buf_add_highlight(b, G.namespace, hi.group, 0, hi.col_start, hi.col_end)
    end
    for _, hi in pairs(profile.groups) do
        vim.api.nvim_set_hl(0, hi.group, hi.val)
    end

    if profile.text == "" or profile.width == 0 then
        vim.api.nvim_win_set_option(w, "winblend", 100)
        vim.api.nvim_win_set_config(w, {
            relative = "editor",
            row = profile.row,
            col = profile.col,
            width = 1,
            height = profile.height,
        })
    else
        vim.api.nvim_win_set_option(w, "winblend", O.blend)
        vim.api.nvim_win_set_config(w, {
            relative = "editor",
            row = profile.row,
            col = profile.col,
            width = profile.width,
            height = profile.height,
        })
    end
end

function M.show()
    G.state = "shown"
    M.update()
end

function M.revive()
    if vim.v.exiting ~= nil then
        return
    end
    local state = G.state
    if state == "shown" then
        M.hide()
        vim.defer_fn(vim.schedule_wrap(M.show), 10)
    end
end

local function stop_sync()
    G.sync = false
end

local delay = 3000
local function sync()
    M.update()
    if G.sync then
        vim.defer_fn(vim.schedule_wrap(sync), delay)
    end
end

local function start_sync()
    G.sync = true
    vim.defer_fn(vim.schedule_wrap(sync), delay)
end

local function check_focus()
    if vim.api.nvim_get_current_win() ~= G.window then
        return
    end

    for _, w in next, vim.api.nvim_list_wins() do
        if w ~= G.window then
            vim.api.nvim_set_current_win(w)
            return
        end
    end
end

local default_option = {
    parts = {
        "branch",
        "remote",
        "ahead",
        "behind",
        "recruit",
        "unmerged",
        "staged",
        "unstaged",
        "untracked",
    },

    prefix = {
        branch = "\u{F418} ", --  .
        remote = "\u{F427} ", --  .
        ahead = "\u{F55D} ", --  .
        behind = "\u{F545} ", --  .
        recruit = "\u{F6C8} ", --  .
        unmerged = "\u{FBC2} ", -- ﯂ .
        staged = "\u{F00C} ", --  .
        unstaged = "\u{F067} ", --  .
        untracked = "\u{F12A} ", --  .
    },

    style = {
        branch = { bg = "Green", fg = "Black" },
        remote = { bg = "Green", fg = "Black" },
        ahead = { bg = "Yellow", fg = "Black" },
        behind = { bg = "Yellow", fg = "Black" },
        recruit = { bg = "Yellow", fg = "Black" },
        unmerged = { bg = "Yellow", fg = "Black" },
        staged = { bg = "Yellow", fg = "Black" },
        unstaged = { bg = "Yellow", fg = "Black" },
        untracked = { bg = "Yellow", fg = "Black" },
    },

    blend = 20,
    commands = {
        GitStatClose = M.hide,
        GitStatShow = M.show,
        GitStatUpdate = M.update,
    },
}

function M.setup(option)
    G.namespace = vim.api.nvim_create_namespace("gitstat")
    O = vim.tbl_deep_extend("force", default_option, option or {})
    if O.commands then
        for cmd, value in pairs(O.commands) do
            vim.api.nvim_add_user_command(cmd, value, { force = true })
        end
    end

    local group = vim.api.nvim_create_augroup("gitstat-global", { clear = true })
    vim.api.nvim_create_autocmd("ShellCmdPost", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("VimResized", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("DirChanged", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("BufWritePost", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("CursorHold", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("CursorHoldI", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("TermResponse", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("TermEnter", { group = group, pattern = "*", callback = M.update })
    vim.api.nvim_create_autocmd("WinEnter", { group = group, pattern = "*", callback = check_focus })
    vim.api.nvim_create_autocmd("TermEnter", { group = group, pattern = "*", callback = start_sync })
    vim.api.nvim_create_autocmd("TermLeave", { group = group, pattern = "*", callback = stop_sync })
end

return {
    setup = M.setup,

    hide = M.hide,
    show = M.show,
    update = M.update,
}
