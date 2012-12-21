:Title: trans.vim
:Author: Rykka
:Version: 0.92
:Github: https://github.com/Rykka/trans.vim
:Update: 2012-12-21

=========
Trans.vim
=========

Tries to make translate words and files in vim easier (from/into English).

Includes bing and google translator.

Installation
------------

Requirment: 

    - Vim compiled with python. 
    - Or webapi.vim_

Install:

    - Vundle::

       Bundle 'Rykka/trans.vim'

Usage
-----

``<leader>tt``
    translate current word or current visual selection.

``:Trans``
    Translate word

    ``:Trans hello`` will print ``你好``

``:TransPo``
    Translate po file

    When in a po buffer, ``:TransPo`` will fill all empty msgstr with translated msgid.

    if the msg is::

        msgid "show all"
        msgstr ""

    it will be translate to::

        msgid "show all"
        msgstr "全部显示"

Options
-------

``g:trans_map_trans``
    mapping for translate , default is '<leader>tt'

``g:trans_default_lang``
    your main language, default is 'zh-CN'

``g:trans_set_reg``
    if is 1, will set the translation to reg ``@"``
    then you can use ``p`` to paste it

    if is 2, will set the translation to reg ``@+``
    then you can use ``<Ctrl-V>`` to paste it

    if it is 0, no reg will be set

    default is 1

``g:trans_echo``
    echo the translation

    if it is 0, will not echo the translation.

    default is 1

``g:trans_engine``
    translator engine, 'google' and 'bing' are valid. default is 'google'

``g:trans_google_url``
    default is 'http://translate.google.com/translate_a/t'

``g:trans_bing_url``
    default is 'https://api.microsofttranslator.com/v2/ajax.svc/Translate'

``g:trans_bing_appid``
    default is 'TpnIxwUGK4_mzmb0mI5konkjbIUY46bYxuLlU1RVGONE*'
    You can use yours if it's invalid.

``g:trans_header_agent``
    default is 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.15 Safari/536.5'


``g:trans_has_python``

    if you want to disable python usage. set it to 0.

    default is your python version.

Know Issues
-----------

* The google url with webapi.vim_ will return a 400 Bad request. 


.. _webapi.vim: https://github.com/mattn/webapi-vim

