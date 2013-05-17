"=============================================
"    Name: trans.vim
"    File: trans.vim
" Summary: Eaiser translate in vim.
"  Author: Rykka G.F
"  Update: 2013-03-14
"=============================================
let s:cpo_save = &cpo
set cpo-=C
" Misc "{{{1
fun! trans#error(msg) "{{{
    echohl ErrorMsg
    echo '[Trans]'
    echohl Normal
    echon a:msg
endfun "}}}
fun! trans#warning(msg) "{{{
    echohl WarningMsg
    echo '[Trans]'
    echohl Normal
    echon a:msg
endfun "}}}

let s:path = expand('<sfile>:p:h').'/'
let s:py_trans = s:path."trans/trans.py"
function! s:py_core_load() "{{{
    exec s:py."file ".s:py_trans
    exec s:py." import vim"
    exec s:py." from vim import command as vcmd"
    exec s:py." from vim import eval as veval"
endfunction "}}}
fun! trans#default(option,value) "{{{
    if !exists(a:option)
        exe "let" a:option "=" string(a:value)
        return 0
    endif
    return 1
endfun "}}}

fun! s:get_visual() "{{{
    let tmp=@@
    sil! norm! gvy
    " let sel = substitute(@@,'[[:cntrl:]]',' ','g')
    let sel = @@
    let @@=tmp
    return sel
endfun "}}}

fun! trans#set(text) "{{{
    if !empty(g:trans_set_reg)
        try 
            exe 'let @'.g:trans_set_reg.' = "'.a:text.'"'
        catch /^Vim\%((\a\+)\)\=:E18/ 
            call trans#error('Invalid register '.g:trans_set_reg.'. check g:trans_set_reg')
        endtry
    endif
    if g:trans_set_echo | redraw | echo a:text | endif
    return a:text
endfun "}}}
" Main "{{{1
let s:token_time = 0
let s:token_str = ''
fun! trans#request(api, text, ...) "{{{
    let api = get(g:trans_api, a:api)
    let text = a:text
    let from = a:0 ? a:1 : ''
    let to = a:0>1 ? a:2 : ''

    if has_key(api, 'query_str')
        let query_str = substitute(api.query_str, '%FROM', from, '')
        let query_str = substitute(query_str, '%TO', to ,'')
        let query_str = substitute(query_str, '%TEXT', webapi#http#encodeURI(text) ,'')
    else
        let query_str = ''
    endif
    let params = has_key(api,'params') ? webapi#http#encodeURI(api.params) : ''
    let headers = has_key(api,'headers') ? api.headers : {}

    if api.type == 'get'
        let query_url =  api.url . '?' . query_str . (strlen(params) ? '&'.params : '' )
        let res = trans#get(query_url, headers)
    elseif api.type == 'post'
        let query_url = api.url
        let post_data = query_str . (strlen(params) ? '&'.params : '' )
        let res = trans#post(query_url, post_data, headers)
    elseif api.type == 'oauth'
        " prepare url for auth
        let now = localtime()
        if now - s:token_time >= api.token_expire
            let s:token_time = now
            let token_res = trans#post(api.oauth_url, api.oauth_obj)
            let token = call(api.token_parser,[token_res])
            let token_str = substitute(api.token_str, '%TOKEN', token,'')
            let s:token_str = token_str
        else
            let token_str = s:token_str
        endif
        let query_url =  api.url . '?' . query_str . '&' . token_str . (strlen(params) ? '&'.params : '' )
        let res = trans#get(query_url, headers)
    endif
    let con = res.content
    let code = has_key(res, 'code') ? res.code : res.header[0]
    if code =~ '200'
        return trans#set(call(api.parser, [con]))
    else
        call trans#error(code .' with '. query_url)
    endif
endfun "}}}
fun! trans#get(url,...) "{{{
    let headers = a:0 ? a:1 : {}
    if g:trans_has_python
        exec s:py 'c = http_get(veval("a:url"),veval("headers"))'
        " FIXED the "'" in dict's string will be escaped 
        "     to "\'" and will make dict break with E722
        " Escape \' to ''
        exec s:py 'c =  str(c).replace("\\''","''''")'
        " exec s:py 'print c'
        " FIXED the '"' in string will cause error
        " Escape "
        exec s:py 'c =  str(c).replace("\\\"","\"")'
        " FIXED the '\n'  will not show as newline
        " Escape \\n to \n
        exec s:py 'c =  str(c).replace("\\\\n","\\n")'
        " exec s:py 'print c'
        exec s:py 'vcmd("let tmp= " + c)'
        return tmp
    else
        return webapi#http#get(a:url,{}, headers)
    endif
endfun "}}}
fun! trans#post(url,data, ...) "{{{
    let headers = a:0 ? a:1 : {}
    let data = webapi#http#encodeURI(a:data)
    if g:trans_has_python
        exec s:py 'c = http_post(veval("a:url"), veval("data"), veval("headers"))'
        exec s:py 'c =  str(c).replace("\\''","''''")'
        exec s:py 'c =  str(c).replace("\\\"","\"")'
        exec s:py 'c =  str(c).replace("\\\\n","\\n")'
        exec s:py 'vcmd("let tmp= " + c)'
        return tmp
    else
        return webapi#http#post(a:url,data,headers)
    endif
endfun "}}}

function! trans#v() range "{{{
    return trans#smart(s:get_visual())
endfunction "}}}
function! trans#v_to() range "{{{
    return trans#to(s:get_visual())
endfunction "}}}
function! trans#v_between() range "{{{
    return trans#between(s:get_visual())
endfunction "}}}
    
fun! trans#smart(word) "{{{
    if a:word =~ '^[[:alnum:][:blank:][:punct:][:cntrl:]]\+$'
        let from = 'en'
        let to = g:trans_default_lang
    else
        let to = 'en'
        let from = g:trans_default_lang
    endif
    return trans#request(g:trans_default_api, a:word, from, to)
endfun "}}}
fun! trans#to(word) "{{{
    let word = a:word
    if word =~ '^[[:alnum:][:blank:][:punct:][:cntrl:]]\+$'
        let from = 'en'
    else
        let from = 'auto'
    endif
    let to = input('[Trans]Input Lang code(en/zh-cn/ja/...):')
    if !empty(to)
        return trans#request(g:trans_default_api, word, from, to)
    endif
endfun "}}}
fun! trans#between(word) "{{{
    let from = input('[Trans]Input From Lang code(en/zh-cn/ja/...):')
    let to = input('[Trans]Input To Lang code(en/zh-cn/ja/...):')
    return trans#request(g:trans_default_api, a:word, from, to)
endfun "}}}

fun! trans#init() "{{{
    call trans#default("g:trans_default_lang" , 'zh-CN'  )
    call trans#default("g:trans_default_from" , 'en'  )
    call trans#default("g:trans_default_api" , 'google'  )
    call trans#default("g:trans_map_trans" , '<leader>tt')
    call trans#default("g:trans_map_to" , '<leader>to')
    call trans#default("g:trans_map_between" , '<leader>tb')
    call trans#default("g:trans_set_reg" , '"')
    call trans#default("g:trans_set_echo" , 1)
    
    if has("python") "{{{
        call trans#default("g:trans_has_python", 2)
    elseif has("python3")
        call trans#default("g:trans_has_python", 3)
    else
        let g:trans_has_python = 0
    endif "}}}

    if g:trans_has_python
        if g:trans_has_python == 2
            let s:py="py"
        elseif g:trans_has_python == 3
            let s:py="py3"
        endif
        call s:py_core_load()
    endif

    call trans#data#init()

endfun "}}}

" Po {{{1
" msgid "show all"
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
