from http.server import HTTPServer

# DONE: add tests for error handling
def start_server(port=8080):
    server = HTTPServer(('', port), None)
    server.serve_forever()

# DONE: add graceful shutdown
def stop_server(server):
    server.shutdown()
