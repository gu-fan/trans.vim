"=============================================
"    Name: trans.vim
"    File: trans.vim
" Summary: Eaiser translate in vim.
"  Author: Rykka G.F
"  Update: 2012-12-19
"=============================================
let s:cpo_save = &cpo
set cpo-=C

" Bing
" http://api.microsofttranslator.com/v2/ajax.svc/Translate?appid=TpnIxwUGK4_mzmb0mI5konkjbIUY46bYxuLlU1RVGONE*&Text=Hello&To=zh-CN

let s:path = expand('<sfile>:p:h').'/'
let s:py_trans = s:path."trans/trans.py"
function! s:py_core_load() "{{{
    if exists("s:py_core_loaded")
        return
    endif
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
    call trans#default("g:trans_default_lang" , 'zh-CN'  )
    call trans#default("g:trans_engine" , 'google'  )
    call trans#default("g:trans_bing_appid" , 'TpnIxwUGK4_mzmb0mI5konkjbIUY46bYxuLlU1RVGONE*'  )
    call trans#default("g:trans_bing_url" , 'https://api.microsofttranslator.com/v2/ajax.svc/Translate'  )
    call trans#default("g:trans_google_url" , 'http://translate.google.com/translate_a/t')
    call trans#default("g:trans_header_agent" , 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.15 Safari/536.5')
    call trans#default("g:trans_set_reg" , 1)
    call trans#default("g:trans_echo" , 1)

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
    if g:trans_has_python
    endif

endfun "}}}

fun! s:set_reg(str) "{{{
    if g:trans_set_reg == 1
        let @" = a:str
    elseif g:trans_set_reg == 2
        let @+ = a:str
    endif
endfun "}}}
function! trans#google(word, from, to)  "{{{
    if g:trans_has_python
        exec s:py 'vcmd("let result_str = ''%s''" % trans_google(veval("a:word"), veval("a:from"),veval("a:to")))'
        call s:set_reg(result_str)
        if g:trans_echo | echo result_str | endif
        return result_str
    else
        try
            " XXX we got a 400 Bad request with this url.
            " curl is not working as the same as urllib2
            let result_obj = webapi#http#get(
                \g:trans_google_url, {
                    \"client" : 'firefox-a',
                    \"langpair" : a:from.'|'.a:to,
                    \"ie" : 'UTF-8',
                    \"oe" : ['UTF-8',webapi#http#encodeURI(a:word)],
                \}, {
                    \'User-Agent': g:trans_header_agent ,
                \})
            " NOTE: google returns a json object.
            let po = eval(result_obj.content)
            let result_str = ''
            for sen in po.sentences
                let result_str += sen.trans
            endfor
            call s:set_reg(result_str)
            if g:trans_echo | echo result_str | endif
            return result_str
        catch /^Vim\%((\a\+)\)\=:E117/ 
            echohl WarningMsg
            echom "trans.vim: Could not translate as you neither have vim compiled with python nor have webapi.vim installed."
            echom v:exception
            echohl Normal
        endtry
    endif
endfunction "}}}

function! trans#bing(word,from,to) "{{{
    " XXX If we want to use the bing api, we should auth it and get the token,
    if g:trans_has_python
        exec s:py 'vcmd("let result_str = ''%s''" % trans_bing(veval("a:word"), veval("a:from"),veval("a:to")))'
        call s:set_reg(result_str)
        if g:trans_echo | echo result_str | endif
        return result_str
    else
        try
            let result_obj = webapi#http#get(
                \g:trans_bing_url, {
                    \"Text" : a:word,
                    \"From" : a:from,
                    \"appId" : g:trans_bing_appid,
                    \"To" : a:to 
                \} ,{
                    \'User-Agent': g:trans_header_agent ,
                \})
            " NOTE: bing return a string like '\uffef"xxx = xxx"'
            if result_obj.content =~ '"'
                let result_obj.content = matchstr(result_obj.content,'"\zs.*\ze"')
            endif
            if result_obj.content =~ ' = '
                let result_str = split(result_obj.content,' = ')[1]
            else
                let result_str = result_obj.content
            endif
            call s:set_reg(result_str)
            if g:trans_echo | echo result_str | endif
            return result_str
        catch /^Vim\%((\a\+)\)\=:E117/ 
            echohl WarningMsg
            echom "trans.vim: Could not translate as you neither have vim compiled with python nor have webapi.vim installed."
            echom v:exception
            echohl Normal
        endtry
    endif
endfunction "}}}

fun! s:get_visual() "{{{
    let tmp=@@
    sil! norm! gvy
    let sel = @@
    let @@=tmp
    return sel
endfun "}}}
function! trans#v() "{{{
    return trans#smart(s:get_visual())
endfunction "}}}

fun! trans#smart(word) "{{{
    if a:word =~ '^[[:alnum:][:blank:][:punct:]]\+$'
        let from = 'en'
        let to = g:trans_default_lang
    else
        let to = 'en'
        let from = g:trans_default_lang
    endif
    if g:trans_engine =='google'
        return trans#google(a:word,from,to)
    else
        return trans#bing(a:word,from,to)
    endif
endfun "}}}

" Translate po file {{{1
" msgid "shown all"
" msgstr "全部显示"
let s:rex_id = 'msgid "\zs[^"[:space:]].*\ze"'
let s:rex_str = 'msgstr ""'
fun! trans#msg_trans(row) "{{{
    let line = getline(a:row)
    if line =~ s:rex_id
        let word = matchstr(line, s:rex_id)
        sil let trans = trans#smart(word)
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
    for row in range(1,line('$'))
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





