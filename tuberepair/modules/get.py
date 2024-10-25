from requests_cache import CachedSession
from jinja2 import Environment, FileSystemLoader
from datetime import timedelta
import requests
import json

# custom functions
import config
from modules import helpers
from .logs import text

# cache to not spam the invidious instance
session = CachedSession('cache/info', expire_after=timedelta(hours=1))

from datetime import datetime

def unix(unix):
    return datetime.fromtimestamp(int(unix)).isoformat() + '.000Z'

def unix_now(): # Will be used in another update
    return datetime.now().isoformat() + '.000Z'

# jinja2 path
env = Environment(loader=FileSystemLoader('templates'))

# simplify requests
def fetch(url):
    try:
        # Without sending User-Agent, the instance wouldn't send any data for {url}/api/v1/videos ... Why?
        url = session.get(url, headers={'User-Agent': 'TubeRepair'}, proxies=helpers.proxies)
        data = url.json()
        return data
    except requests.ConnectionError:
        text('INVIDIOUS INSTANCE FAILED!', 'red')

def template(file, render_data):
    t = env.get_template(file)
    output = t.render(render_data)
    return output

def error():
    return "",404



