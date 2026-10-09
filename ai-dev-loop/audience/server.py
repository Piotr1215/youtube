#!/usr/bin/env python3
"""The audience page for Step 8: one fixed question, answered by Winnow on the T4.

On the laptop it serves index.html and POST /api/classify on 127.0.0.1 only, the
Cloudflare tunnel being the sole way in, and asks through ../ask. In a cluster
(classifier/) CLASSIF_HOSTS names the model Service, it runs classif directly and
binds AUDIENCE_BIND. Either way it uses an argv list, never a shell, and returns
only the label, its probability and the time. The text goes in on stdin, never in
argv: classif would read text such as "-i/etc/passwd" as an option. Input is capped,
requests are rate limited per client and bounded overall. Nothing logs the text:
classif's question form does not write its log, and CLASSIF_LOG points at a
private directory that audience.sh deletes in case a later classif does.

    CLASSIF_LOG=/private/dir/log.jsonl python3 -I server.py [PORT]
"""
import collections
import json
import os
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HERE = Path(__file__).resolve().parent
# In a cluster the model is a Service name; on the laptop ../ask looks up its IP.
ASK = "classif" if os.environ.get("CLASSIF_HOSTS") else str(HERE.parent / "ask")
PAGE = (HERE / "index.html").read_bytes()
QUESTION = "Is this a Kubernetes problem?"
MAX_TEXT = 500
MAX_BODY = 4096
# Requests per minute. Conference WiFi puts a room behind one address, so the
# per-client limit is loose; the overall one and GPU_SLOTS protect the T4.
PER_CLIENT = 30
OVERALL = 240
GPU_SLOTS = threading.BoundedSemaphore(3)
QUEUE_WAIT = 15  # seconds a request waits for a slot before the page says busy

hits = collections.defaultdict(collections.deque)
hits_lock = threading.Lock()
answers = collections.Counter()


def allowed(client):
    """Sliding one-minute windows, per client and overall."""
    now = time.monotonic()
    with hits_lock:
        windows = [(hits[client], PER_CLIENT), (hits[None], OVERALL)]
        for window, limit in windows:
            while window and now - window[0] > 60:
                window.popleft()
            if len(window) >= limit:
                return False
        for window, _ in windows:
            window.append(now)
        return True


def classify(text):
    """Ask the T4 and keep only the public fields of classif's JSON."""
    started = time.monotonic()
    try:
        out = subprocess.run([ASK, "-j", "-d", "20", QUESTION], input=text, capture_output=True,
                             text=True, timeout=30, cwd=HERE).stdout
        result = json.loads(out)
    except (subprocess.TimeoutExpired, ValueError):
        return None
    label = result.get("label")
    if label not in ("yes", "no", "unknown"):
        return None
    answers[label] += 1
    return {"label": label, "p": round(result["p"][label], 2),
            "seconds": round(time.monotonic() - started, 1)}


class Handler(BaseHTTPRequestHandler):
    server_version = "audience"
    sys_version = ""

    def send(self, status, body, kind="application/json"):
        if not isinstance(body, bytes):
            body = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", kind)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Content-Security-Policy",
                         "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/":
            self.send(200, PAGE, "text/html; charset=utf-8")
        elif self.path == "/healthz":
            self.send(200, {"answers": sum(answers.values()), **answers})
        else:
            self.send(404, {"error": "not found"})

    def do_POST(self):
        if self.path != "/api/classify":
            return self.send(404, {"error": "not found"})
        # Behind the tunnel every request comes from cloudflared on localhost.
        client = self.headers.get("CF-Connecting-IP") or self.client_address[0]
        if not allowed(client):
            return self.send(429, {"error": "slow down"})
        try:
            size = int(self.headers.get("Content-Length", 0))
            if not 0 < size <= MAX_BODY:
                raise ValueError
            text = json.loads(self.rfile.read(size)).get("text", "")
            text = " ".join(str(text).split())
        except (ValueError, AttributeError):
            return self.send(400, {"error": "bad request"})
        if not text or len(text) > MAX_TEXT:
            return self.send(400, {"error": f"1 to {MAX_TEXT} characters"})
        if not GPU_SLOTS.acquire(timeout=QUEUE_WAIT):
            return self.send(503, {"error": "busy"})
        try:
            result = classify(text)
        finally:
            GPU_SLOTS.release()
        self.send(200, result) if result else self.send(503, {"error": "unavailable"})

    def log_message(self, *args):
        pass  # never log what attendees type


if __name__ == "__main__":
    if not os.environ.get("CLASSIF_LOG"):
        sys.exit("set CLASSIF_LOG to a private path; audience.sh does this")
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8089
    bind = os.environ.get("AUDIENCE_BIND", "127.0.0.1")
    ThreadingHTTPServer((bind, port), Handler).serve_forever()
