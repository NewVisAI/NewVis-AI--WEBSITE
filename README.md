# Sentinel AI — Marketing Site

A self-contained marketing website + lead-capture form for **Sentinel AI**, the
general-purpose AI video-analytics platform by **Adiva** that turns existing CCTV
cameras into real-time safety intelligence (schools, malls, parking, offices,
warehouses, and more).

The page is a single glassmorphism `landing.html`. A tiny FastAPI backend
(`app.py`) serves it and stores "Request a callback" submissions in a local
SQLite database — no dependency on the main Sentinel product code.

## Run locally

```bash
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8000
```

Open <http://localhost:8000>.

## How the lead form works

The site's callback modal (soft gate: opens on exit-intent, deep scroll, or any
"Request a callback" button) POSTs JSON to `/api/leads`:

```
{ name, email, phone, org, use_case, message, website }
```

- `website` is a **honeypot** — real users leave it empty; filled submissions are
  silently accepted but not stored.
- Name, email and phone are required; the email is format-checked.
- Rows are written to `leads.db` with the source IP and a UTC timestamp.

### Viewing submitted leads

`GET /api/leads` is **disabled by default** (returns 403) so contact details are
never exposed by accident. To enable it, set an admin key and send it as a header:

```bash
ADMIN_KEY=your-secret uvicorn app:app --port 8000
curl -H "X-Admin-Key: your-secret" http://localhost:8000/api/leads
```

Or read the SQLite file directly:

```bash
sqlite3 leads.db "SELECT created_at, name, phone, email, use_case FROM leads ORDER BY id DESC;"
```

## Configuration

| Env var         | Default        | Purpose                                            |
| --------------- | -------------- | -------------------------------------------------- |
| `LEADS_DB_PATH` | `./leads.db`   | Where submissions are stored.                      |
| `ADMIN_KEY`     | *(unset)*      | Enables `GET /api/leads` when the header matches.   |

## Add real dashboard screenshots

The hero shows an animated mock until a real screenshot is present. Drop an image
at `static/marketing/dashboard-hero.png` and it replaces the mock automatically.

## Notes

- `leads.db` is git-ignored — it holds real contact data and must not be committed.
- Copy is intentionally honest: Production features are stated plainly; Beta
  features (fall, running, fight, cross-camera Re-ID) are labelled as Beta and no
  unmeasured accuracy numbers are published.
