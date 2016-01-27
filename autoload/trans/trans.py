#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

if sys.version_info.major==2:

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


else:

    import urllib.request

    def http_get(url, headers):
        req = urllib.request.Request(
            url = url,
            headers = headers
        )
        f = urllib.request.urlopen(req, None, 3)
        con = f.read()
        return {'code':f.getcode(), 'content':con.decode()}

    def http_post(url, data, headers):
        req = urllib.request.Request(
            url = url,
            headers = headers
        )
        f = urllib.request.urlopen(req, data.encode(), 3)
        con = f.read()
        return {'code':f.getcode(), 'content':con.decode()}

