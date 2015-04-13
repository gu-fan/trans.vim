#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import urllib,urllib2

def http_get(url, headers):
    req = urllib2.Request(
        url = url,
        headers = headers
    )
    f = urllib2.urlopen(req, None, 3)
    con = f.read()
    return {'code':f.getcode(), 'content':con}

def http_post(url, data, headers):
    req = urllib2.Request(
        url = url,
        headers = headers
    )
    f = urllib2.urlopen(req, data, 3)
    con = f.read()
    return {'code':f.getcode(), 'content':con}

