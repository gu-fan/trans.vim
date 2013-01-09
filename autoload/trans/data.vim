"=============================================
"    Name: data.vim
"    File: data.vim
" Summary: data of translator APIs
"  Author: Rykka G.F
"  Update: 2013-01-09
"=============================================
let s:cpo_save = &cpo
set cpo-=C


" Google API (web page) "{{{1
" No key for oauth version
" URL: http://translate.google.com/translate_a/t?client=firefox-a&langpair=auto|zh-cn&ie=UTF-8&oe=UTF-8&text=HELLO
" {"sentences":[{"trans":"HELLO","orig":"HELLO","translit":"HELLO","src_translit":""}],"dict":[{"pos":"感叹词","terms":["喂"],"entry":[{"word":"喂","reverse_translation":["hello","hey"],"score":0.0087879393}]}],"src":"en","server_time":28}

call trans#default("g:trans_api" , {})

let g:trans_api.google = {
            \'url': 'http://translate.google.com/translate_a/t',
            \'params' : {
                    \"client" : 'firefox-a',
                    \"ie" : 'UTF-8',
                    \"oe" : 'UTF-8',
                    \},
            \'query_str': 'langpair=%FROM%7C%TO&text=%TEXT',
            \'parser': 'trans#data#parser_google',
            \'type': 'get',
            \'headers': { 'User-Agent': 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.15 Safari/536.5' },
            \}

fun! trans#data#parser_google(con) "{{{
    let po = type(a:con) == type({}) ? a:con : eval(a:con)
    return join(map(po.sentences, 'v:val.trans'), ' ')
endfun "}}}

" Microsoft translator  (need update token) "{{{1
" URL: http://api.microsofttranslator.com/v2/ajax.svc/Translate?appid=TpnIxwUGK4_mzmb0mI5konkjbIUY46bYxuLlU1RVGONE*&Text=Hello&To=zh-CN
"
" Bing (need auth)
" XXX: not working
" URL: https://api.datamarket.azure.com/Bing/MicrosoftTranslator/v1/Translate?Text=%27hello%27&To=%27zh-CHT%27&From=%27en%27
let g:trans_api.bing = {'url': 'http://api.microsofttranslator.com/v2/ajax.svc/Translate',
            \'type': 'oauth',
            \'oauth_url': 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/',
            \'oauth_obj': {
                        \'client_id' : '086296d7-e63f-48f3-9ce8-36233efa7b0a',
                        \'client_secret' : 'YFPq/2G/cz5DnLASQTa1gy8ts3QGuTUBagt1qljkUis=',
                        \'scope' : 'http://api.microsofttranslator.com',
                        \'grant_type' : 'client_credentials',
                        \},
            \'token_str': 'appId=Bearer%20%TOKEN',
            \'token_expire': 600,
            \'token_parser': 'trans#data#parser_t_bing',
            \'parser': 'trans#data#parser_bing',
            \'query_str': 'from=%FROM&to=%TO&text=%TEXT',
            \}
fun! trans#data#parser_bing(con) "{{{
    let con = a:con
    if  con =~ '"'
        let con = matchstr(con,'"\zs.*\ze"')
    endif
    " convert '\xff\xff' to character
    return con =~ '\\[xu]\x\x' ? eval('"'.con.'"') : con
endfun "}}}
fun! trans#data#parser_t_bing(res) "{{{
    return webapi#http#encodeURI(webapi#json#decode(a:res.content).access_token)
endfun "}}}

" Baidu API (en,zh-cn only) "{{{1
" key: XrPxmIZ2nq4GgKGMxZmGPM5r
" URL: http://openapi.baidu.com/public/2.0/bmt/translate?client_id=XrPxmIZ2nq4GgKGMxZmGPM5r&q=today&from=auto&to=auto
" {"from":"zh","to":"en","trans_result":[{"src":"\u4f60\u597d","dst":"Hello"}]}
let g:trans_api.baidu = {
            \'url': 'http://openapi.baidu.com/public/2.0/bmt/translate',
            \'query_str' : 'q=%TEXT&from=%FROM&to=%TO',
            \'type' : 'get',
            \'params' : {'client_id': 'XrPxmIZ2nq4GgKGMxZmGPM5r'},
            \'parser' : 'trans#data#parser_baidu',
            \}
fun! trans#data#parser_baidu(con) "{{{
    let po = type(a:con) == type({}) ? a:con : eval(a:con)
    let con = join(map(po.trans_result, 'v:val.dst'), ' ')
    " convert '\uffff\ufff' to character
    return con =~ '\\[xu]\x\x' ? eval('"'.con.'"') : con
endfun "}}}


" Youdao API (en,zh-cn only) "{{{1
" keyfrom： trans-vim     key：  1050975093
" URL: http://fanyi.youdao.com/openapi.do?keyfrom=trans-vim&key=1050975093&type=data&doctype=json&version=1.1&q=要翻译的文本 
"  {"translation":["Translate the text"],"query":"要翻译的文本","errorCode":0}

let g:trans_api.youdao = {'url': 'http://fanyi.youdao.com/openapi.do',
            \'query_str' : 'q=%TEXT',
            \'type' : 'get',
            \'params' : {'key': '1050975093',
                        \'keyfrom': 'trans-vim',
                        \'doctype': 'json',
                        \'version': '1.1',
                        \'type': 'data',
                        \},
            \'parser' : 'trans#data#parser_youdao',
            \}
fun! trans#data#parser_youdao(con) "{{{
    let po = type(a:con) == type({}) ? a:con : eval(a:con)
    let con = join(po.translation, ' ')
    " convert '\uffff\ufff' to character
    return con =~ '\\[xu]\x\x' ? eval('"'.con.'"') : con
endfun "}}}

fun! trans#data#init() "{{{
    " dummy func to reload current script
endfun "}}}

let &cpo = s:cpo_save
unlet s:cpo_save
