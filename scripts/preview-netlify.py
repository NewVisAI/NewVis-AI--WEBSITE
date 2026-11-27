"""Preview the Netlify copy locally, behaving like Netlify does:
/privacy serves privacy.html, /favicon.ico serves the SVG icon, unknown pages get 404.html.

    sh scripts/build-netlify.sh
    python scripts/preview-netlify.py            # then open http://newvis.localhost:8210

Opened at newvis.localhost (not localhost), the callback form sends to the real Google Sheet,
exactly like the live site. On plain localhost it uses the Python app's /api/leads instead.
"""
import os
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

DIST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "dist")
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8210


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=DIST, **k)

    def do_GET(self):
        path = self.path.split("?", 1)[0].split("#", 1)[0]
        if path == "/favicon.ico":
            self.path = "/static/favicon.svg"
        elif path != "/" and "." not in path.rsplit("/", 1)[-1] and os.path.isfile(os.path.join(DIST, path.strip("/") + ".html")):
            self.path = path.rstrip("/") + ".html"
        target = os.path.join(DIST, self.path.split("?", 1)[0].lstrip("/"))
        if self.path.split("?", 1)[0] != "/" and not os.path.exists(target):
            with open(os.path.join(DIST, "404.html"), "rb") as f:
                body = f.read()
            self.send_response(404)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        super().do_GET()


if __name__ == "__main__":
    print(f"Previewing dist/ at http://newvis.localhost:{PORT}  (Ctrl+C to stop)", flush=True)
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
