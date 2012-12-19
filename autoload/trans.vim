"=============================================
"    Name: trans.vim
"    File: trans.vim
" Summary: Eaiser translate in vim.
"  Author: Rykka G.F
"  Update: 2012-12-19
"  Credit: google from jiazhoulvke
"=============================================
let s:cpo_save = &cpo
set cpo-=C

let s:path = expand('<sfile>:p:h').'/'
let s:py_trans = s:path."trans/trans.py"
let s:BING_TRANSLATE_API = "http://api.bing.net/json.aspx"
let s:bing_trans_api = "https://api.datamarket.azure.com/Bing/MicrosoftTranslator/v1/"
function! s:py_core_load() "{{{
    " if exists("s:py_core_loaded")
    "     return
    " endif
    let s:py_core_loaded=1
    exec s:py."file ".s:py_trans
endfunction "}}}
fun! trans#default(option,value) "{{{
    if !exists(a:option)
        let {a:option} = a:value
        return 0
    endif
    return 1
endfun"}}}
    
fun! trans#init() "{{{
        if has("python") "{{{
        call trans#default("g:trans_has_python"     , 2                )
        let s:py="py"
        call s:py_core_load()
    elseif has("python3")
        call trans#default("g:trans_has_python"     , 3                )
        let s:py="py3"
        call s:py_core_load()
    else
        let g:trans_has_python = 0
    endif "}}}
    call trans#default("g:trans_default_to" , 'zh-CN'  )
    call trans#default("g:trans_default_from"   , 'en'  )
    call trans#default("g:trans_engine"   , 'google'  )
    call trans#default("g:trans_bing_user"   , 'test@test.com'  )
    call trans#default("g:trans_bing_api"   , 'bJdSABqAVp/JQ0eA5jlMXmc7hqOy4dPye1Rga1GF6yA='  )
endfun "}}}

function! trans#google(word, from, to) " "{{{
    if g:trans_has_python
        exec s:py 'vcmd("return ''%s''" % trans_google(veval("a:word"), veval("a:from"),veval("a:to")))'
    else
        echohl WarningMsg
        echom "trans.vim: Could not translate as you have no python installed."
        echohl Normal
    endif
endfunction "}}}

function! trans#bing(string,from,to) "{{{
    " We could not use the basic api login anymore!!
    let l:result_json = webapi#http#get(
        \s:bing_trans_api,{
        \"Text" : '%27'.webapi#http#encodeURI(a:string).'%27',
        \"From" : a:from,
        \"format" : 'json',
        \"appId" : g:trans_bing_api,
        \"To" : '%27'.a:to.'%27'})
    let l:traslate_result = webapi#xml#parse(l:result_json.content)
    "let l:traslate_result = webapi#json#decode(l:result_json.content)
    return l:traslate_result
endfunction "}}}

fun! s:get_visual() "{{{
    let tmp=@@
    sil! norm! gvy
    let sel = @@
    let @@=tmp
    return sel
endfun "}}}
function! trans#v(from,to) "{{{
    return trans#google(a:lan1,a:lan2,s:get_visual())
endfunction "}}}

fun! trans#smart(word) "{{{
    if a:word =~ '^[[:alnum:][:blank:][:punct:]]\+$'
        let from = 'en'
        let to = g:trans_default_to
    else
        let to = 'en'
        let from = g:trans_default_to
    endif
    if g:trans_engine =='google'
        return trans#google(a:word,from,to)
    else
        return trans#bing(a:word,from,to)
    endif
endfun "}}}

" Translate po file {{{1

"
" msgid "shown for all"
" msgstr "全部显示"
let s:rex_id = 'msgid "\zs[^"[:space:]].*\ze"'
let s:rex_str = 'msgstr ""'
fun! trans#msg_trans(row) "{{{
    let line = getline(a:row)
    if line =~ s:rex_id
        let word = matchstr(line, s:rex_id)
        let trans = trans#google('en', 'zh-CN',word)
        return trans
    else
        return ''
    endif
endfun "}}}
fun! trans#msg_repl(row, trans) "{{{
    let line = getline(a:row)
    if line =~ s:rex_str
        let line = printf('msgstr "%s"', a:trans)
        call setline(a:row, line)
    endif
endfun "}}}
fun! trans#trans_po() "{{{
    let trans = ''
    for row in range(20,line('$'))
    " for row in range(140,160)
        let line = getline(row)
        if line =~ s:rex_str
            let trans = trans#msg_trans(row-1)
            if trans != ''
                call trans#msg_repl(row, trans)
            endif
        endif
    endfor
endfun "}}}





