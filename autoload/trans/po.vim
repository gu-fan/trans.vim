"=============================================
"    Name: po.vim
"    File: po.vim
" Summary: translation of po file
"  Author: Rykka G.F
"  Update: 2013-05-11
"=============================================
let s:cpo_save = &cpo
set cpo-=C

" For Po file, we should use a statemachine to check the msg id and string.
" 
" 1. single line translation
" msgid "xxxx"
" msgstr ""
"
" 2. multi line translation
" msgid ""
" "xxxx"
" "xxxx"
" msgstr ""
" 
" 3. plural translation
" msgid "1 item"
" msgid_plural " items"
" msgstr[0] ""
" msgstr[1] ""
"
" 4. python format
" msgid
" "matching your query: %(query)s\n"
" msgstr ""

" StateMachine:
" Run:
"
" state: no trans
" check for #: xxxxxx , record as template path
" check for #, python-format: set python fmt on.
" check for msgid: 
"           add following lines to trans_src
" check for msgid_plural: 
"           set plural on
"           add following lines to trans_src_plural
" if plural off
"   check for msgstr
" else
"   check for msgstr[0], msgstr[1]
"
"   then translate the string and return the value

" To reduce http request, we should bundle msgstr
" use ------- as transition

" To keep python format
" Use $1, $2, ... as place holder


" Using matchlist to get next state of line,
" which can match 9 sub match at the most.
let s:quote = '".*"'

let s:s_ptn = '\v(^msgid ".*"$)'
             \.'|(^msgid_plural ".*"$)'
             \.'|(^msgstr ".*"$)'
             \.'|(^msgstr\[0\] ".*"$)'
             \.'|(^msgstr\[1\] ".*"$)'
             \.'|(^".*"$)'
             \.'|(^#, python-format$)'
             \.'|(^#\s*.*$)'
             \.'|(^\s*$)'
let s:ptn_line = '"\zs.*\ze"$'
" next means this state can change to.
" empty list means keep current state
" other state switching will throw an error.
let s:s = {
        \-1: {'name': 'Error'       , 'next': []      , },
        \ 0: {'name': 'No Input'    , 'next': [0,1]     , },
        \ 1: {'name': 'msgId Start' , 'next': [2,3] , },
        \ 2: {'name': 'msgId Plural', 'next': [4]   , },
        \ 3: {'name': 'msgStr'      , 'next': [0]   , },
        \ 4: {'name': 'msgStr[0]'   , 'next': [5]   , },
        \ 5: {'name': 'msgStr[1]'   , 'next': [0]   , },
        \ 6: {'name': 'Pure Str'    , 'next': []      , },
        \ 7: {'name': 'Comment'     , 'next': []      , },
        \ 8: {'name': 'Comment Py'  , 'next': []      , },
        \ 9: {'name': 'Empty Line'  , 'next': [0]     , },
        \ }



let s:st = {}
fun! s:st.init(from, to) dict "{{{
    " create a state machine for current buffer
    " create a DOC tree for current buffer
    " set init state
    let st = {}
    let st.doc = []
    let st.from = a:from
    let st.to = a:to
    let st.state = 0
    let st.buf_len = line('$')
    " we add a empty line for EOF
    let st.buf = getline(1, st.buf_len) + ['']
    let st.trans_buf = copy(st.buf)
    let st.options = {'py':0, 'plural':0}
    let st.cur_str = ""     " str for translation
    let st.cur_str_p = ""
    let st.cur_trans = 0    " whether translation already exists
    let st.cur_trans_p = 0

    let st.cur_row = 0
    let st.cur_start_row = 0
    let st.cur_trans_row = 0
    let st.cur_trans_p_row = 0
    " let st.new_doc = []
    fun! st.run() dict
        for i in range(self.buf_len+1)
        " for line in self.buf
            " let [self.state, self.doc, self.buf] = s:check_line(line, self)
            try
                redraw
                echo i '/' self.buf_len
                call self.check_line(i)
            catch /\[Trans\.vim\] Error/
                echohl ErrorMsg
                echom 'Error! at line ' . (i+1)
                echom v:exception
                echohl Normal
                echom self.buf[i]
            endtry
        endfor
    endfun
    fun! st.check_line(row) dict

        " NOTE: Row start from index0
        let line = self.buf[a:row]
        let self.cur_row = a:row

        " Check current line and get it's switch
        let mt = matchlist(line, s:s_ptn)
        if empty(mt)
            let switch = -1 
            throw "[Trans.vim] Error: Error Format of Line."
        else
            let switch = -1 
            " check if is an empty string
            if mt[0] == "" 
                let switch = 0
            else
                for i in range(1,8) " check mt[1:9]
                    if !empty(mt[i])
                        let switch = i
                        break
                    endif
                endfor
            endif
        endif

        " get 'next' state from cur_state's nexts, if exists,
        " then next state is the switch
        let cur = self.state
        if !empty(s:s[cur].next)
            if index(s:s[cur].next, switch) != -1
                let next = switch
            else
                if switch < 6
                    " switch >= 6 does not change state
                    throw "[Trans.vim] Error: Switch State Error."
                else
                    let next = cur
                endif
            endif
        else
            let next = cur
        endif
    
        let str = matchstr(line, s:ptn_line)
        if switch == 1
            let self.cur_start_row = a:row
            let self.cur_str = str
        elseif switch == 2
            let self.cur_str_p = str
            let self.options.plural = 1
        elseif cur == 1 && switch == 3 
            let self.cur_trans_row = a:row
            if !empty(str)
                let self.cur_trans = 1
            endif
        elseif cur == 2 && switch == 4 
            let self.cur_trans_row = a:row
            if !empty(str)
                let self.cur_trans = 1
            endif
        elseif cur == 4 && switch == 5
            let self.cur_trans_p_row = a:row
            if !empty(str)
                let self.cur_trans_p = 1
            endif
        elseif switch == 6
            " Not modify the state for switch 6
            if cur == 1
                " XXX translation willl 
                " add an space before each new line
                if !empty(str)
                    let self.cur_str .= "\n".str 
                endif
            elseif cur == 2
                if !empty(str)
                    let self.cur_str_p .= "\n".str 
                endif
            elseif cur == 3 && self.cur_trans == 0
                if !empty(str)
                    let self.cur_trans = 1
                endif
            elseif cur == 4 && self.cur_trans == 0
                if !empty(str)
                    let self.cur_trans = 1
                endif
            elseif cur == 5 && self.cur_trans_p == 0
                if !empty(str)
                    let self.cur_trans_p = 1
                endif
            endif
        elseif switch == 7
            let self.options.py = 1
        elseif switch == 8
            " Comments, Do Nothing
        elseif switch == 9
            if cur != 0
                let self.options = {'py':0, 'plural':0}
                let self.cur_str = ""
                let self.cur_str_p = ""
                let self.cur_trans = 0
                let self.cur_trans_p = 0
            endif
        elseif switch == 0 && ( cur==3 || cur == 5)
            " Acutally do the translation work!

            " If translated , ignore it.
            let trans_src = ""
            let trans_src_p = ""
            if self.cur_trans == 0
                let trans_src = self.cur_str
            endif
            if cur == 5 && self.cur_trans_p == 0
                let trans_src_p = self.cur_str_p
            endif

            " Get Trans
            let tmp = [g:trans_set_reg, g:trans_set_echo]
            let g:trans_set_reg = ""
            let g:trans_set_echo = 0

            if !empty(trans_src)
                " substitude py string
                let [trans_src, subs] = s:substr(trans_src)
                let trans = trans#request(g:trans_default_api,
                            \trans_src, self.from, self.to)
                if !empty(subs)
                    let trans = s:restr(trans, subs)
                endif
            endif

            if cur == 5 && !empty(trans_src_p)
                let [trans_src_p, subs] = s:substr(trans_src_p)
                let trans_p = trans#request(g:trans_default_api,
                            \trans_src_p, self.from, self.to)
                if !empty(subs)
                    let trans_p = s:restr(trans_p, subs)
                endif
            endif

            let [g:trans_set_reg, g:trans_set_echo] = tmp

            " Modify buf
            if exists("l:trans")
                if cur == 5
                    let self.trans_buf[self.cur_trans_row] = 
                                \ "msgstr[0] \""
                                \.trans."\""
                else
                    let self.trans_buf[self.cur_trans_row] =
                                \ "msgstr \""
                                \.trans."\""
                endif
            endif

            if cur == 5 && exists("l:trans_p")
                let self.trans_buf[self.cur_trans_p_row] =
                            \ "msgstr[1] \""
                            \.trans_p."\""
            endif

            " Reset state
            let self.options = {'py':0, 'plural':0}
            let self.cur_str = ""
            let self.cur_str_p = ""
            let self.cur_trans = 0
            let self.cur_trans_p = 0
        endif

        let self.state = next
    endfun

    return st
endfun "}}}

fun! trans#po#init(...) "{{{
    let from = a:0 ? a:1 : g:trans_default_from
    let to = a:0>1 ? a:2 : g:trans_default_lang
    let st = s:st.init(from, to)
    call st.run()

    " Change translated lines only
    for i in range(st.buf_len)
        if st.buf[i] != st.trans_buf[i]
            call setline((i+1), st.trans_buf[i])
        endif
    endfor

    " split line with " " ctrl-q_ctrl-j
    let i = 0
    while i <= line('$')
        let i += 1
        let line = getline(i)
        if line =~ '\n'
            " google trans will add a space befor newline
            let line = substitute(line, '\n\s\=', '"\n"','g')
            let lines = split(line, '\n')
            call setline(i , lines[0])
            call append(i, lines[1:])
        endif
    endwhile
endfun "}}}

" TODO: substitude the html tag
let s:py_ptn = '%(\w\+)s'
let s:py_sub = 'PY__SUBSTR__'
fun! s:substr(str) "{{{
    " change current str's py format to _SUBSTR_,
    " return a new string and a list of the sub strings
    let str = a:str
    let subs = []
    while match(str, s:py_ptn ) != -1
        let sub = matchstr(str, s:py_ptn)
        let str = substitute(str , s:py_ptn, s:py_sub ,'')
        call add(subs, sub)
    endwhile
    return [str, subs]
endfun "}}}
fun! s:restr(str,subs) "{{{
    " restore str with subs.
    let str = a:str
    let subs = a:subs
    while match(str, s:py_sub ) != -1
        let str = substitute(str ,s:py_sub ,remove(subs, 0) ,'')
    endwhile
    return str
endfun "}}}

if expand("<sfile>:p") == expand("%:p")
    " let str = 'msgstr "aaafff"'
    " " let str = '#msg "aaafff"'
    " let str = "msgstr[0] \"aaa\""
    " let str = "msgstr[0] \"\""
    " echo matchlist(str, s:s_ptn)
    let text = 'aaaa %(aa)s aaaabbb ajijeoij %(ajiej)s %(aaaa)s'
    let [str, sub] =  s:substr( text )
    echo str sub
    let str = s:restr(str, sub)
    echo str
    echo str == text
endif

let &cpo = s:cpo_save
unlet s:cpo_save
