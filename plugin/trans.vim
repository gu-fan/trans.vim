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

call trans#default("g:trans_map_trans" , '<leader>tt')
if !hasmapto(g:trans_map_trans)
    nmap <silent> <leader>tt :cal trans#smart(expand('<cword>'))<CR> 
    vmap <silent> <leader>tt :cal trans#v()<CR> 
endif

command! -nargs=+ Trans cal trans#smart(<q-args>)
command! TransPo call translate#trans_po()

let &cpo = s:cpo_save
unlet s:cpo_save
