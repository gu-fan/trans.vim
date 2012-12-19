"=============================================
"    Name: trans.vim
"    File: trans.vim
" Summary: eaiser tranlsate in vim
"  Author: Rykka G.F
"  Update: 2012-12-19
"=============================================
let s:cpo_save = &cpo
set cpo-=C

call trans#init()

if !hasmapto('<leader>tt','n')
    nmap <silent> <leader>tt :echo trans#smart(expand('<cword>'))<CR> 
endif
if !hasmapto('<leader>e2c','n')
    nmap <silent> <leader>e2c :echo trans#google(expand('<cword>'),'en','zh-CN')<CR>
endif
if !hasmapto('<leader>c2e','n')
    nmap <silent> <leader>c2e :echo trans#google(expand('<cword>'),'zh-CN','en')<CR>
endif
if !hasmapto('<leader>e2c','v')
    vmap <silent> <leader>e2c <ESC>:echo trans#v('en','zh-CN')<CR>
endif
if !hasmapto('<leader>c2e','v')
    vmap <silent> <leader>c2e <ESC>:echo trans#v('zh-CN','en')<CR>
endif
if !exists(":E2C")
    command! -nargs=+ E2C :echo trans#google("en","zh-CN",<q-args>)
endif
if !exists(":C2E")
    command! -nargs=+ C2E :echo trans#google("zh-CN","en",<q-args>)
endif

if !exists(":TPO")
    command! TPO call translate#trans_po()
endif

let &cpo = s:cpo_save
unlet s:cpo_save
