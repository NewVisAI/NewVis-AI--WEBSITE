"""
Sentinel AI — marketing site + lead capture (standalone).

A tiny, self-contained FastAPI app that serves the glassmorphism landing page
and stores "Request a callback" submissions in a local SQLite database. It has
no dependency on the main Sentinel product code — just FastAPI + uvicorn.

Run:
    pip install -r requirements.txt
    uvicorn app:app --host 0.0.0.0 --port 8000
    # open http://localhost:8000

Environment:
    LEADS_DB_PATH     Path to the SQLite file (default: ./leads.db)
    ADMIN_KEY         If set, GET /api/leads requires header  X-Admin-Key: <value>.
                      If unset, GET /api/leads is disabled (403) so the call list
                      is never exposed by accident.
"""

import os
import sqlite3
from datetime import datetime, timezone
from typing import Optional

from fastapi import FastAPI, HTTPException, Request, Header
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.environ.get("LEADS_DB_PATH") or os.path.join(BASE_DIR, "leads.db")
ADMIN_KEY = os.environ.get("ADMIN_KEY", "")

app = FastAPI(title="Sentinel AI — Marketing", version="1.0.0")

STATIC_DIR = os.path.join(BASE_DIR, "static")
os.makedirs(os.path.join(STATIC_DIR, "marketing"), exist_ok=True)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


class LeadRequest(BaseModel):
    name: str
    email: str
    phone: str
    org: Optional[str] = ""
    use_case: Optional[str] = ""
    message: Optional[str] = ""
    website: Optional[str] = ""  # honeypot: real users leave this empty


def _conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS leads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            org TEXT,
            use_case TEXT,
            message TEXT,
            source_ip TEXT,
            created_at TEXT NOT NULL
        )
        """
    )
    return conn


def _client_ip(request: Optional[Request]) -> Optional[str]:
    if request is None:
        return None
    fwd = request.headers.get("x-forwarded-for")
    if fwd:
        return fwd.split(",")[0].strip()
    return request.client.host if request.client else None


@app.get("/", response_class=HTMLResponse)
def landing():
    path = os.path.join(BASE_DIR, "landing.html")
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            return HTMLResponse(content=f.read())
    return HTMLResponse(content="<h3>landing.html missing.</h3>", status_code=404)


@app.post("/api/leads")
def create_lead(lead: LeadRequest, request: Request):
    # Honeypot: silently accept bots without storing them.
    if (lead.website or "").strip():
        return {"ok": True}

    name = (lead.name or "").strip()
    email = (lead.email or "").strip()
    phone = (lead.phone or "").strip()
    if not name or not email or not phone:
        raise HTTPException(status_code=422, detail="Name, email and phone are required.")
    if "@" not in email or "." not in email.split("@")[-1]:
        raise HTTPException(status_code=422, detail="Please provide a valid email address.")

    conn = _conn()
    try:
        conn.execute(
            "INSERT INTO leads (name, email, phone, org, use_case, message, source_ip, created_at) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            (
                name[:120],
                email[:160],
                phone[:30],
                (lead.org or "").strip()[:160],
                (lead.use_case or "").strip()[:120],
                (lead.message or "").strip()[:1000],
                _client_ip(request),
                datetime.now(timezone.utc).isoformat(),
            ),
        )
        conn.commit()
    finally:
        conn.close()
    return {"ok": True}


@app.get("/api/leads")
def list_leads(x_admin_key: str = Header(default="")):
    """Call-list view. Disabled unless ADMIN_KEY is set and the header matches."""
    if not ADMIN_KEY or x_admin_key != ADMIN_KEY:
        raise HTTPException(status_code=403, detail="Forbidden.")
    conn = _conn()
    try:
        conn.row_factory = sqlite3.Row
        rows = conn.execute(
            "SELECT id, name, email, phone, org, use_case, message, source_ip, created_at "
            "FROM leads ORDER BY id DESC"
        ).fetchall()
    finally:
        conn.close()
    return {"count": len(rows), "leads": [dict(r) for r in rows]}


@app.get("/healthz")
def healthz():
    return {"ok": True}
