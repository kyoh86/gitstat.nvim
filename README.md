# gitstat.nvim

A lua plugin for neovim that shows git-status on the top of the editor.

![gitstat](https://user-images.githubusercontent.com/5582459/111492408-fbcc5200-877f-11eb-9150-ae8b6f4a6b0f.png)

## setup

```lua
require('gitstat').show()
```

## highlights

There's some Highlight groups:

- GitStatWindow
- GitStatBranch
- GitStatRemote
- GitStatAhead
- GitStatBehind
- GitStatSync
- GitStatUnmerged
- GitStatStaged
- GitStatUnstaged
- GitStatUntracked

You can customize them with |:hightlight|

## commands

- GitStatClose  / lua require('gitstat').hide()
- GitStatShow   / lua require('gitstat').show()
- GitStatUpdate / lua require('gitstat').update()

## options

### `gitstat#prefix#*`

Prefixes for the parts of the stat.

Default:

```
gitstat#prefix#branch = "\u{F418} ",     --  .
gitstat#prefix#remote = "\u{F427} ",     --  .
gitstat#prefix#ahead = "\u{FF55D} ",     -- 󿕝 .
gitstat#prefix#behind = "\u{FF545} ",    -- 󿕅 .
gitstat#prefix#sync = "\u{F12A} ",       --  .
gitstat#prefix#unmerged = "\u{FFBC2} ",  -- 󿯂 .
gitstat#prefix#staged = "\u{FF62B} ",    -- 󿘫 .
gitstat#prefix#unstaged = "\u{FF914} ",  -- 󿤔 .
gitstat#prefix#untracked = "\u{FF7D5} ", -- 󿟕 .
```

### `gitstat#parts`

Comma-separated and ordered parts which you want to show.

Default: branch,remote,ahead,behind,sync,unmerged,staged,unstaged,untracked

### `gitstat#blend`

'winblend' of the window for gitstat.

Default: 40
