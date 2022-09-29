**Deprecated as api getting changed**
use `translate-shell.vim` instead

:translate-shell.vim: https://github.com/echuraev/translate-shell.vim

:Title: trans.vim
:Author: Rykka
:Version: 1.51
:Github: https://github.com/Rykka/trans.vim
:Update: 2013-05-17

=========
Trans.vim
=========

**Trans.vim** makes translation in vim easier.
::

    Trans.vim使翻译在vim更容易。
    Trans.vimはvimでの変換が容易になります。
    Trans.vim rend la traduction dans vim facile.
    Транс.вим чини превод на вим лакше.
    ...


What's New
----------

Add replace option by default.


Installation
------------

Requirment: 

    - Vim compiled with python. (or webapi.vim_)

Install:

    - Vundle_:

      In your vimrc::
      
       Bundle 'Rykka/trans.vim'
       " for no python version
       " Bundle 'mattn/webapi-vim'
      
      Then use ``:BundleInstall`` to install. 

Usage
-----

``:Trans`` ``<leader>tt`` 
    Translate.
    word under cursor or current visual selection.

    e.g. ':Trans hello' will echo ``你好`` and set register ``@"`` to 你好

``:TransTo`` ``<leader>to`` 
    Translate word with input lang code.


``:TransBetween`` ``<leader>tb``
    Translate with lang code From and To.


``:TransPo [[FROM],[TO]]``
    Translate po file.
    [FROM] and [TO] are lang code and can be ommited.

    For a buffer of Po, 
    ``:TransPo`` will fill translate msgid.

    Following function included:

        Plural message translation.
        Python format string '%(item)s' will be keeped.
        Multiline string Translation.


Options
-------


``g:trans_default_api``
    Translator engine, 'google', 'bing', 'baidu', 'youdao' are valid. 

    default is 'google'.

    see APIS_ for details.
``g:trans_default_lang``
    Your main language, default is 'zh-CN'

``g:trans_map_trans``
    Mapping for translate , default is '<leader>tt'

``g:trans_map_to``
    Mapping for translate to lang code, default is '<leader>to'

``g:trans_set_reg``
    The register for you to set. 

    default is '"' means ``@"``.

    you can set it to '+' to clip to ``@+``.

    or you can set it to '_' to ignore it.

``g:trans_set_echo``
    After translation, echo the result.

    set it to 0, to disable it.

    default is 1


``g:trans_has_python``
    compiled with python or not.

    set it to 0 to disable using python, thus webapi.vim_ is needed.

    default is your python version.

``g:trans_replace``

    replace current words or selection,
    
    default is 1.

APIs
----

There are several built-in APIs, and you can define your own API
to use other translators.

Define your own API
  if your API need only 'GET' method, then in your vimrc::
    
    " init default apis
    call trans#data#init()
    
    " API_QUERY_STR is something like 'text=%TEXT&from=%FROM&to=%TO'
    " API_PARSER_FUNC is the name of the function to parse the response content
    " And you can add 'headers' key for specified headers dict
    let g:trans_api.YOUR_API = {
        \'type': 'get',
        \'url': YOUR_API_URL,
        \'params': YOUR_API_PARAMS,
        \'query_str': API_QUERY_STR,
        \'parser': API_PARSER_FUNC,
        \}

    fun! API_PARSER_FUNC(content)
        " parse content here.
        return a:content 
    endfun


Then you can use it with ``let g:trans_default_api = 'YOUR_API'``,

or ``:call trans#request('YOUR_API',text,from,to)`` 

You can see the built-in APIs for references.

Google
~~~~~~

This is the web API. Which may violate the term of google translator.

No oauth API added as that needs billing.

:: 

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

Bing
~~~~

It's using microsoft translator API actually.

Use your key as the built-in key have limit of 2000000 char per month.

Get your key for oauth_obj:

1. create the live account live_
2. get the client_id (customer ID) at datamarket_ 
3. get the client_secret at developer_ (create a app with client_id)
4. Active microsoft translator API at translator_data_

::

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

Baidu
~~~~~

Only 'en' and 'zh-cn',

Create your key at Baidu-Api_

:: 
    
    let g:trans_api.baidu = {
                \'url': 'http://openapi.baidu.com/public/2.0/bmt/translate',
                \'query_str' : 'q=%TEXT&from=%FROM&to=%TO',
                \'type' : 'get',
                \'params' : {'client_id': 'XrPxmIZ2nq4GgKGMxZmGPM5r'},
                \'parser' : 'trans#data#parser_baidu',
                \}
    
Youdao
~~~~~~

Only 'en' and 'zh-cn'

Create a new key at youdao-api_, the default key is limit to 1000 per hour.

:: 

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
    



ChangeLog
---------

* 1.5

    - Add ``:TransBetween``
    - Fix the "\"" and "'" and "\n" with python api.
    - Rewrite TransPo.

      Now work better than auto trans by google translate toolkit.




.. _webapi.vim: https://github.com/mattn/webapi-vim
.. _Vundle: https://github.com/gmarik/vundle
.. _datamarket: https://datamarket.azure.com/account 

.. _live: http://home.live.com/

.. _developer: https://datamarket.azure.com/developer/applications/

.. _translator_data: https://datamarket.azure.com/dataset/bing/microsofttranslator 
.. _youdao-api: http://fanyi.youdao.com/openapi?path=data-mode

.. _Baidu-Api: http://developer.baidu.com/wiki/index.php?title=%E5%B8%AE%E5%8A%A9%E6%96%87%E6%A1%A3%E9%A6%96%E9%A1%B5/%E7%99%BE%E5%BA%A6%E7%BF%BB%E8%AF%91/%E7%BF%BB%E8%AF%91API
