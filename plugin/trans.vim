"=============================================
"    Name: trans.vim
"    File: trans.vim
" Summary: define map and commands
"  Author: Rykka G.F
"  Update: 2013-01-09
"=============================================
let s:cpo_save = &cpo
set cpo-=C

call trans#init()

if !hasmapto(g:trans_map_trans)
    exe 'nmap <silent> '.g:trans_map_trans.' :cal trans#smart(expand("<cword>"))<CR>'
    exe 'vmap <silent> '.g:trans_map_trans.' :cal trans#v()<CR>'
    exe 'nmap <silent> '.g:trans_map_to.' :cal trans#to(expand("<cword>"))<CR>'
    exe 'nmap <silent> '.g:trans_map_between.' :cal trans#between(expand("<cword>"))<CR>'
    exe 'vmap <silent> '.g:trans_map_to.' :cal trans#v_to()<CR>'
    exe 'vmap <silent> '.g:trans_map_between.' :cal trans#v_between()<CR>'
endif

command! -nargs=+ Trans cal trans#smart(<q-args>)
command! -nargs=+ TransTo cal trans#to(<q-args>)
command! -nargs=+ TransBetween cal trans#between(<q-args>)
command! -nargs=* TransPo cal trans#po#init(<f-args>)

let &cpo = s:cpo_save
unlet s:cpo_save
