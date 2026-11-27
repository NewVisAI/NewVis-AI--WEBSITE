# NewVis AI — Marketing Website

Premium dark neon marketing website + lead-capture platform for **NewVis AI**, an advanced AI video-analytics solution that transforms existing CCTV cameras into intelligent real-time safety systems (schools, malls, parking, offices, warehouses, and more).

**Single-file frontend** (`landing.html`) — no build step, no framework, no bundler. Lightweight FastAPI backend (`app.py`) serves the page and stores "Request a callback" submissions in SQLite. 100% self-contained with zero dependencies on other services.

---

## 🚀 Quick Start (3 Steps)

### ✅ Prerequisites
Before starting, make sure you have:
- **Python 3.9+** installed (check: `python --version` or `python3 --version`)
- **Git** installed (check: `git --version`)
- **pip** (comes with Python)

**Don't have Python?** Download from [python.org](https://www.python.org/downloads/) (Windows: choose "Add Python to PATH" during install)

### 📋 Step 1: Clone the Repository

**Windows (Command Prompt or PowerShell):**
```bash
git clone https://github.com/NewVisAI/NewVis-AI--WEBSITE.git
cd "NewVis-AI--WEBSITE"
```

**macOS/Linux (Terminal):**
```bash
git clone https://github.com/NewVisAI/NewVis-AI--WEBSITE.git
cd NewVis-AI--WEBSITE
```

### 🔧 Step 2: Create Virtual Environment & Install Dependencies

**Windows (Command Prompt):**
```bash
python -m venv venv
venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
```

**Windows (PowerShell):**
```bash
python -m venv venv
venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
```

**macOS/Linux (Terminal):**
```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 🎯 Step 3: Run the Server

**All platforms (after activating venv):**
```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

📱 **Open in browser:** http://localhost:8000

To stop the server, press `Ctrl+C`

---

## 🛠️ System Requirements

| Component | Requirement |
|-----------|------------|
| **Python** | 3.9 or higher (3.10+ recommended) |
| **pip** | Latest version |
| **OS** | Windows, macOS, Linux |
| **RAM** | 512MB minimum |
| **Disk** | ~50MB (dependencies + leads database) |
| **Port** | 8000 (configurable via `--port` flag) |

---

## 📦 Dependencies

All dependencies are listed in `requirements.txt`:

```
fastapi>=0.110        # Web framework
uvicorn[standard]>=0.29  # ASGI server
pydantic>=2.0        # Data validation
```

Install all at once:
```bash
pip install -r requirements.txt
```

---

## 🔧 Advanced Configuration

### Running on a different port
```bash
uvicorn app:app --host 0.0.0.0 --port 3000
```

### Running with auto-reload (development)
```bash
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

### Enable admin API for lead access
```bash
ADMIN_KEY=your-secret-key uvicorn app:app --port 8000
curl -H "X-Admin-Key: your-secret-key" http://localhost:8000/api/leads
```

### Custom SQLite database path
```bash
LEADS_DB_PATH=/custom/path/leads.db uvicorn app:app --port 8000
```

---

## ✅ Testing Locally

### 1. Verify Server is Running
Open your browser and go to: http://localhost:8000

You should see the **NewVis AI** homepage with:
- Dark neon theme (purple and cyan colors)
- Hero section with "Any space. Every camera"
- "Request a callback" button in top right

### 2. Test Lead Form (Complete Flow)
1. Click the **"Request a callback"** button in the top right
2. A modal popup should appear: "Let's talk about your site"
3. Fill in the form:
   - **Name:** Test User
   - **Email:** test@example.com
   - **Phone:** +1-555-0123
   - **Organization:** Test Company (optional)
   - **Use case:** Select "School / campus"
   - **Message:** Test message (optional)
4. Click **"Request my callback"**
5. You should see: "Thanks — we'll be in touch"

### 3. Verify Lead Was Saved to Database

**Windows (Command Prompt):**
```bash
sqlite3 leads.db "SELECT * FROM leads ORDER BY id DESC LIMIT 1;"
```

**macOS/Linux:**
```bash
sqlite3 leads.db "SELECT * FROM leads ORDER BY id DESC LIMIT 1;"
```

You should see a row with your test data (name, email, phone, etc.)

### 4. Quick Health Check
In your terminal, run (in a different terminal while server is running):
```bash
curl http://localhost:8000/healthz
```

Expected response: `{"ok":true}`

---

## 🐛 Troubleshooting

### ❌ "Address already in use" or "Port 8000 is already in use"

**Problem:** Another program is using port 8000.

**Solution 1: Use a different port**
```bash
uvicorn app:app --host 0.0.0.0 --port 8001
# Then visit: http://localhost:8001
```

**Solution 2: Kill the process using port 8000**

**Windows (Command Prompt, run as Admin):**
```bash
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

**Windows (PowerShell, run as Admin):**
```bash
Get-Process -Id (Get-NetTCPConnection -LocalPort 8000).OwningProcess
```

**macOS/Linux:**
```bash
lsof -i :8000
kill -9 <PID>
```

---

### ❌ "ModuleNotFoundError: No module named 'fastapi'"

**Problem:** Dependencies not installed or virtual environment not activated.

**Solution:**
1. Verify you're in the project directory: `cd <project-path>`
2. Activate virtual environment:
   - **Windows:** `venv\Scripts\activate`
   - **macOS/Linux:** `source venv/bin/activate`
3. Install dependencies: `pip install -r requirements.txt`
4. Verify: `pip list` should show `fastapi` and `uvicorn`

---

### ❌ "python: command not found" (macOS/Linux)

**Problem:** Python not installed or not in PATH.

**Solution:**
- Check if Python is installed: `python3 --version`
- Use `python3` instead of `python` for all commands:
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  ```

---

### ❌ "'venv' is not recognized" (Windows)

**Problem:** Virtual environment not created or wrong path.

**Solution:**
1. Delete existing venv: `rmdir /s venv` (or `rm -r venv` in PowerShell)
2. Recreate: `python -m venv venv`
3. Activate: `venv\Scripts\activate`
4. Verify prompt shows `(venv)` at the start

---

### ❌ Browser shows "localhost refused to connect"

**Problem:** Server isn't running or isn't listening on port 8000.

**Solution:**
1. Check terminal output — look for: `Uvicorn running on http://0.0.0.0:8000`
2. If not present, restart server: `uvicorn app:app --host 0.0.0.0 --port 8000`
3. Try again: http://localhost:8000
4. If still failing, check for errors above "Port already in use"

---

### ❌ Lead form doesn't submit or shows error

**Problem:** Server is running but form submission fails.

**Solution:**
1. Open browser DevTools: Press `F12`
2. Go to **Console** tab — look for red error messages
3. Go to **Network** tab — click "Request my callback" and look for failed requests
4. Common issues:
   - Missing required fields (name, email, phone, use case)
   - Email format invalid (must include `@`)
   - Server not responding (see "Browser shows localhost refused")

---

### ❌ Database file won't delete (Windows)

**Problem:** `rm leads.db` doesn't work or says file is in use.

**Solution:**
1. Stop the server: Press `Ctrl+C` in the terminal
2. Delete via File Explorer: Find `leads.db` and press `Delete`
3. Or in command prompt: `del leads.db`
4. Restart server: `uvicorn app:app --host 0.0.0.0 --port 8000`

---

### ❌ Getting "Permission denied" errors

**Problem:** Virtual environment or file permissions issue.

**Solution (Windows):**
```bash
# Open Command Prompt as Administrator
# Then run activation and pip commands
venv\Scripts\activate
pip install -r requirements.txt
```

**Solution (macOS/Linux):**
```bash
# Add execute permission
chmod +x venv/bin/activate
source venv/bin/activate
pip install -r requirements.txt
```

---

### ✅ Still Stuck?

1. **Check terminal output:** Look for error messages above the "Uvicorn running" line
2. **Verify file structure:** You should have: `landing.html`, `app.py`, `requirements.txt`, `Dockerfile`, `README.md`
3. **Try fresh install:**
   ```bash
   deactivate  # Exit virtual environment
   rm -r venv  # Delete virtual environment
   python -m venv venv  # Create fresh one
   venv\Scripts\activate  # (Windows) or source venv/bin/activate (Mac/Linux)
   pip install -r requirements.txt
   uvicorn app:app --host 0.0.0.0 --port 8000
   ```

---

## 🎨 Design & Development

### Working on this with Claude Code

The AI tooling used to build this page (design-system skills, animation
references, the 21st.dev MCP server) is **not** committed — it is ~13MB of
third-party content. To get the same setup on your machine:

```bash
bash scripts/setup-agent-skills.sh
```

See **[docs/AGENT-SETUP.md](docs/AGENT-SETUP.md)** for the full guide, including
how to get your own API keys. None of this is needed to just run the site.

### Project Layout

| Path | What it is |
| ---- | ---------- |
| `landing.html` | The landing page: markup, styles and JS in one file, including the product tour. |
| `privacy.html`, `404.html` | Privacy notice (DPDP Act 2023, linked from the form and footer) and not-found page. |
| `app.py` | FastAPI server: serves the pages, accepts leads, security headers, `/healthz`. |
| `static/showcase/` | Product-tour images: `dashboard/*.webp` are real dashboard screenshots, `tracking.jpg` a pipeline frame. Faces are blurred. |
| `tools/capture_dashboard.py` | Retakes the tour screenshots from a running NewVis server (see its docstring). |
| `test_leads.py` | `python -m unittest test_leads`: leads reach the database, spam is rejected, the call list is protected. |
| `leads.db` | SQLite lead store. Git-ignored: it holds real contact data. |

### Design System

Dark canvas with cyan and violet accents, glass cards and one gradient for primary actions. All
design decisions live in CSS custom properties at the top of the `<style>` block: change tokens
there rather than hard-coding values.

| Token | Value | Use |
| ----- | ----- | --- |
| `--bg` | `#05070f` | Page canvas |
| `--cyan` | `#37d6f0` | Primary accent, CTAs, links |
| `--violet` | `#8b7bff` | Secondary accent, gradient partner |
| `--ink` | `#e8edf7` | Headings |
| `--ink-soft` | `#aab6cc` | Body copy |
| `--safe` / `--amber` / `--red` | | **Semantic only**: Production badge / Beta badge / alerts. Don't reuse for decoration. |

Type is the system UI stack (Inter if installed), so the page loads no web fonts or third-party
scripts, and the Content-Security-Policy in `app.py` allows only this site.

**Product tour.** Six tabs, each labelled Production or Beta to match `FEATURE_STATUS.md` in the
NewVis repo. Keep those labels honest when features change. To refresh the screenshots, run
`tools/capture_dashboard.py` against a NewVis server and check every image for faces before pushing.

## How the lead form works

The callback modal (opens on exit-intent, deep scroll, or any "Request a callback" button) POSTs
JSON to `/api/leads`:

```
{ name, email, phone, org, use_case, message, website }
```

- `website` is a **honeypot**: real users leave it empty; filled submissions are silently accepted
  but not stored.
- Name, phone, email and use case are required; email and phone are format-checked.
- Each IP may submit 5 times an hour (`LEADS_PER_HOUR`).
- Rows are written to `leads.db` with the source IP, browser user-agent and a UTC timestamp.
- If `SMTP_HOST` and `LEADS_NOTIFY_TO` are set, every lead is also emailed to the team.

This field list is a contract between `landing.html`, `app.py` and `tools/leads-google-sheet.gs`:
change all three together.

### Hosting on Netlify (newvis.gensolve.in)

The live site is a static copy of the pages on Netlify, so the Python app doesn't run there. Instead,
the form posts to a small Google Apps Script that saves each lead as a row in a Google Sheet and
emails the team.

- **Build:** `netlify.toml` runs `scripts/build-netlify.sh`, which copies `landing.html` (as
  `index.html`), `privacy.html`, `404.html` and `static/` into `dist/`. The same security headers as
  `app.py` are set in `netlify.toml`.
- **Leads:** set `LEADS_URL` in `landing.html` to the Apps Script web-app URL (ends in `/exec`). On
  `localhost` the form still uses the Python `/api/leads`, so local testing is unchanged. If
  `LEADS_URL` is empty, the form always uses `/api/leads`.
- **Setting up the Sheet:** follow the steps at the top of `tools/leads-google-sheet.gs`. Leads appear
  in the Sheet with an Indian-time timestamp, and each one is emailed to the Sheet's owner. Replying to
  that email replies to the visitor.
- **Spam:** the honeypot still applies. There's no visitor IP in Apps Script, so the limits are 3
  requests an hour per email address and 60 an hour across the whole site.
- **Preview the Netlify copy locally:** run `sh scripts/build-netlify.sh`, then
  `python scripts/preview-netlify.py`, and open <http://newvis.localhost:8210>. It behaves like
  Netlify (`/privacy`, `/favicon.ico`, the 404 page). The form sends to the real Google Sheet there,
  so any test you submit becomes a real row and email.
- **Self-hosting instead:** `docker-compose.yml` and `Caddyfile` still run the Python app with HTTPS
  on a server, if we ever move off Netlify.

### Viewing submitted leads

`GET /api/leads` is **disabled by default** (returns 404) so contact details are
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

## The hero camera wall

The hero's "live analytics" window is an animated HTML/CSS mock, not a video or
screenshot, so it stays light and sharp at any size. It lives in `#heroMock` in
`landing.html`; its text labels are part of the page copy.

---

## 🚢 Deployment

### Option 1: Docker (Easiest)

**Prerequisites:** Docker installed ([get Docker](https://www.docker.com/products/docker-desktop))

**Build and run:**
```bash
docker build -t newvis-website .
docker run -p 8000:8000 newvis-website
```

Then visit: http://localhost:8000

**To stop:** Press `Ctrl+C` or run `docker stop <container-id>`

### Option 2: Production Server (Linux/macOS)

For production with multiple workers:
```bash
ADMIN_KEY=your-secret-key uvicorn app:app --host 0.0.0.0 --port 8000 --workers 4
```

### Option 3: Docker Compose (Both Services)

If you want to run **both website and dashboard** together:

**From the parent directory:**
```bash
docker-compose up -d
```

This starts:
- Website: http://localhost:8000
- Dashboard: http://localhost:8002

See `DEPLOYMENT.md` for advanced production setup (Nginx, systemd, cloud).

---

## ✨ Before You Ship a Change

- Check at 375 / 768 / 1024 / 1440 px — no horizontal scroll at any width.
- Test the lead form end-to-end (submit, then confirm the row lands in `leads.db`).
- Toggle "reduce motion" in your OS and confirm the page is still readable and static.
- Keep copy honest — see below.

---

## 📋 Notes & Guidelines

### Git Ignore
- `leads.db` — Git-ignored. Contains real contact data; never commit.
- `.claude/` — Git-ignored. Local Claude Code tooling, not part of product.
- `venv/` — Virtual environment. Never commit.
- `.env` — Environment variables. Never commit.

### Content Guidelines
- **Production features** — State plainly with measured accuracy numbers
- **Beta features** (fall detection, cross-camera Re-ID, etc.) — Label as "Beta"
- **Honest positioning** — No unmeasured claims. This is a deliberate choice.
- **Keep this convention** — The Production/Beta split is intentional positioning

### Browser Support
- ✅ Chrome/Edge (full Chromium support)
- ✅ Firefox (graceful degradation: plain blur instead of refraction)
- ✅ Safari (graceful degradation: plain blur instead of refraction)
- ⚠️ IE11 — Not supported

---

## 📞 Support & Feedback

- **Issues:** <https://github.com/NewVisAI/SENTINEL-WEBSITE/issues>
- **Discussions:** <https://github.com/NewVisAI/SENTINEL-WEBSITE/discussions>
- **Email:** support@newvis.ai

---

## 📄 License

NewVis AI — Premium Video Analytics Platform. All rights reserved.
