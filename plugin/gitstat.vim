lua require('gitstat').init()

highlight! default GitStatWindow ctermbg=4 ctermfg=0 guibg=DarkRed guifg=Black
highlight! default GitStatBranch ctermbg=4 ctermfg=0 guibg=DarkRed guifg=Black
highlight! default GitStatRemote ctermbg=4 ctermfg=0 guibg=DarkRed guifg=Black
highlight! default GitStatAhead ctermbg=12 ctermfg=0 guibg=Red guifg=Black
highlight! default GitStatBehind ctermbg=12 ctermfg=0 guibg=Red guifg=Black
highlight! default GitStatSync ctermbg=12 ctermfg=0 guibg=Red guifg=Black
highlight! default GitStatUnmerged ctermbg=12 ctermfg=0 guibg=Red guifg=Black
highlight! default GitStatStaged ctermbg=12 ctermfg=0 guibg=Red guifg=Black
highlight! default GitStatUnstaged ctermbg=12 ctermfg=0 guibg=Red guifg=Black
highlight! default GitStatUntracked ctermbg=12 ctermfg=0 guibg=Red guifg=Black

command! GitStatClose lua require('gitstat').hide()
command! GitStatShow lua require('gitstat').show()
command! GitStatUpdate lua require('gitstat').update()

augroup GitStat
  autocmd!
  autocmd ShellCmdPost * lua require('gitstat').update()
  autocmd VimResized   * lua require('gitstat').update()
  autocmd DirChanged   * lua require('gitstat').update()
  autocmd BufWritePost * lua require('gitstat').update()
  autocmd CmdlineLeave * lua require('gitstat').update()
  autocmd CursorHold   * lua require('gitstat').update()
  autocmd CursorHoldI  * lua require('gitstat').update()
  autocmd TermResponse * lua require('gitstat').update()
  autocmd TermEnter    * lua require('gitstat').update()
  autocmd TermEnter    * lua require('gitstat').start_sync()
  autocmd TermLeave    * lua require('gitstat').stop_sync()
augroup END
