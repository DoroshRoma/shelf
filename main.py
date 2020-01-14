#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from mess import Request, Response, Router, NotFound
from wsgiref.simple_server import make_server
from db import MedicDB


def patients(request):
    # Get all patients from db
    password = 'password123'
    medicdb = MedicDB(password)
    print(medicdb.get_all_from_table('Patients'))

    name = request.args.get('name', 'Guest')
    return Response(f"<h1>Hello, {name}</h1>")

routes = Router()
routes.add_route('/patients', patients)
routes.add_route('/', patients)

def app(environ, start_response):
    try:
        request = Request(environ)
        callback = routes.match(request.path)
        response = callback(request)
    except NotFound:
        response = Response("<h1>Not Found</h1>", status=404)

    start_response(response.status, response.headers.items())
    return iter(response)
    
if __name__ == '__main__':
    port = 8000
    host = 'localhost'
    with make_server(host, port, app) as server:
        print(f"Serving on host: {host} at port: {port}")
        server.serve_forever()