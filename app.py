from bottle import static_file, route, request, response, \
                   run, abort, HTTPResponse
import os.path
import json
from functools import wraps
from base64 import b64decode

SITE_PATH = 'site'
DEV_MODE = True
CACHE_TIME = 60

def cache(fn):
    if DEV_MODE:
        return fn
    @wraps(fn)
    def inner(*args, **kwargs):
        result = fn(*args, **kwargs)
        response.set_header('Cache-Control',
                            'public, max-age={}'.format(CACHE_TIME))
        return result
    return inner

def simple_auth_example(username, password):
    if username == password:
        return {'username': username,
                'teams': ['SRZ', 'SRZ2'],
                'firebase-token': 'bees',
                'admin': True}
    return None

def need_auth(mechanism):
    def wrapper(fn):
        login = HTTPResponse('Authorization Required',
                             status=401,
                             headers={'WWw-Authenticate': 'Basic realm="IDE"',
                                      'Content-Type': 'text/plain'})
        @wraps(fn)
        def inner(*args, **kwargs):
            auth_token = request.headers.get('Authorization')
            if auth_token is None:
                return login
            # Decode auth token
            (auth_type, auth_code) = auth_token.split(' ')
            if auth_type != 'Basic':
                return login
            auth_text = b64decode(auth_code.encode('utf-8'), validate=True)
            auth_elements = auth_text.decode('utf-8').split(':')
            auth_results = mechanism(*auth_elements)
            if auth_results is None:
                return login
            result = fn(auth_results, *args, **kwargs)
            return result
        return inner
    return wrapper

def static(*subpaths, mime='auto'):
    return static_file(os.path.join(*subpaths),
                       root=SITE_PATH,
                       mimetype=mime)

@route('/')
@need_auth(simple_auth_example)
def index(data):
    with open(os.path.join(SITE_PATH, 'index.html')) as f:
        content = f.read()
    encoded = content.format(auth_data=json.dumps(data))
    return HTTPResponse(encoded,
                        status=200,
                        headers={'Content-Type': 'text/html; charset=UTF-8',
                                 'Content-Language': 'en'})

@route('/ide.css')
@cache
def css():
    return static('ide.css', mime='text/css')

@route('/ide.js')
@cache
def css():
    return static('ide.js', mime='application/javascript')

@route('/ide.map')
def source_map():
    return static('ide.map', mime='application/json')

@route('/src/<item:path>')
def source(item):
    return static('src', item, mime='text/coffeescript')

@route('/fonts/<item>.svg')
@cache
def font_svg(item):
    return static('fonts', '{}.svg'.format(item), mime='image/svg+xml')

@route('/fonts/<item>.ttf')
@cache
def font_ttf(item):
    return static('fonts', '{}.ttf'.format(item), mime='application/x-font-ttf')

@route('/fonts/<item>.woff')
@cache
def font_woff(item):
    return static('fonts', '{}.woff'.format(item), mime='application/font-woff')

if __name__ == '__main__':
    run(host='::', port=5112)

