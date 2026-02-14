from http.server import HTTPServer

# TODO: add tests for error handling
def start_server(port=8080):
    server = HTTPServer(('', port), None)
    server.serve_forever()

# TODO: add graceful shutdown
def stop_server(server):
    server.shutdown()
