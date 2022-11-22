# gitstat.nvim

Deprecated: We can use winbar and laststatus=3 instead.

A lua plugin for neovim that shows git-status on the top of the editor.

![gitstat](https://user-images.githubusercontent.com/5582459/111492408-fbcc5200-877f-11eb-9150-ae8b6f4a6b0f.png)

## Setup

You can configure this plugin with "setup" function.
It accepts options and also having default values like below.

```lua
require('gitstat').setup({
    -- Ordered parts which you want to show.
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

    -- A table of prefixes for each part.
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

    -- A table of styles like |nvim_set_hl()| for each part.
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

    -- 'winblend' of the window for gitstat.
    blend = 20,
})
```

## Show

You should call a "show" function to see git status window.

```lua
require("gitstat").show()
```

## Commands

- GitStatClose  / lua require('gitstat').hide()
- GitStatShow   / lua require('gitstat').show()
- GitStatUpdate / lua require('gitstat').update()

