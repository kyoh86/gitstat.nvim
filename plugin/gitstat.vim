highlight! default GitStatWindow guifg=Yellow guibg=black gui=inverse

command! GitStatClose lua require('gitstat').hide()
command! GitStatShow lua require('gitstat').show()
command! GitStatUpdate lua require('gitstat').update()

augroup GitStat
  autocmd!
  autocmd BufWritePost * lua require('gitstat').update()
  autocmd TermEnter * lua require('gitstat').start_sync()
  autocmd TermLeave * lua require('gitstat').stop_sync()
augroup END
