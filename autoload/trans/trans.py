# coding=utf-8
# Credit: google tranlsate from jiazhoulvke
import vim,urllib,urllib2
from vim import eval as veval
from vim import command as vcmd

headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.15 Safari/536.5'
}


def trans_google(word,lang_from,lang_to):
    word=word.replace('\n','')
    rword = urllib.urlencode({'text':word})

    url = 'http://translate.google.com/translate_a/t?client=firefox-a&langpair='+lang_from+'%7c'+lang_to+'&ie=UTF-8&oe=UTF-8&'+rword

    req = urllib2.Request(
        url = url,
        headers = headers
    )
    gtresult = urllib2.urlopen(req)
    resultstr=''
    if gtresult.getcode()==200:
        gtresultstr=gtresult.read()
        po=eval(gtresultstr)
        resultstr=''
        for poi in po['sentences']:
            resultstr+=poi['trans']
        if po.has_key('dict'):
            if len(po['dict'])>0:
                if po['dict'][0].has_key('terms'):
                    tr=','.join(po['dict'][0]['terms'])
                    resultstr+='\n'+word+':'+tr
    return resultstr

def trans_google(word,lang_from,lang_to):
    word=word.replace('\n','')
    rword = urllib.urlencode({'text':word})

    url = 'http://translate.google.com/translate_a/t?client=firefox-a&langpair='+lang_from+'%7c'+lang_to+'&ie=UTF-8&oe=UTF-8&'+rword

    req = urllib2.Request(
        url = url,
        headers = headers
    )
    gtresult = urllib2.urlopen(req)
    resultstr=''
    if gtresult.getcode()==200:
        gtresultstr=gtresult.read()
        po=eval(gtresultstr)
        resultstr=''
        for poi in po['sentences']:
            resultstr+=poi['trans']
        if po.has_key('dict'):
            if len(po['dict'])>0:
                if po['dict'][0].has_key('terms'):
                    tr=','.join(po['dict'][0]['terms'])
                    resultstr+='\n'+word+':'+tr
    return resultstr