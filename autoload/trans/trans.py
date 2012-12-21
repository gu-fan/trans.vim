# coding=utf-8
# Credit: google tranlsate from jiazhoulvke
import urllib,urllib2

from vim import eval as veval
from vim import command as vcmd

headers = { 'User-Agent': veval('g:trans_header_agent') }

google_url = veval('g:trans_google_url')
bing_url = veval('g:trans_bing_url')
bing_appid = veval('g:trans_bing_appid')

def trans_google(word,lang_from,lang_to):
    word=word.replace('\n','')
    rword = urllib.urlencode({'text':word})

    url = google_url+'?client=firefox-a&langpair='+lang_from+'%7c'+lang_to+'&ie=UTF-8&oe=UTF-8&'+rword

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
    return resultstr

def trans_bing(word,lang_from,lang_to):
    word=word.replace('\n','')
    rword = urllib.urlencode({'text':word})

    url = bing_url+'?appid='+bing_appid+'&To='+lang_to+'&Text='+rword

    req = urllib2.Request(
        url = url,
        headers = headers
    )
    gtresult = urllib2.urlopen(req)
    resultstr=''
    if gtresult.getcode()==200:
        gtresultstr=gtresult.read()
        if ' = ' in gtresultstr:
            gtresultstr = re.search(r'"(.*)"',gtresultstr).group(1)
            resultstr = gtresultstr.split(' = ')[1]
        else:
            resultstr = gtresultstr
    return resultstr 
