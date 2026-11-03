# NewVis AI — Marketing Website

Premium dark neon marketing website + lead-capture platform for **NewVis AI**, an advanced AI video-analytics solution that transforms existing CCTV cameras into intelligent real-time safety systems (schools, malls, parking, offices, warehouses, and more).

**Single-file frontend** (`landing.html`) — no build step, no framework, no bundler. Lightweight FastAPI backend (`app.py`) serves the page and stores "Request a callback" submissions in SQLite. 100% self-contained with zero dependencies on other services.


> **Comparing two designs (branch `claude/confident-cannon-gp60qh`).** Run the server as below, then open
> **http://localhost:8000/** (the redesigned page) and **http://localhost:8000/alt** (the NewVis.AI page with
> the product tour of real dashboard screenshots). Both share one lead database, `/privacy` and the 404 page.
> Once a design is picked, the other page and the `/alt` route are removed.
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
| `landing.html` | The entire front end — markup, styles and JS in one file. Read the comment block at the top before editing. |
| `app.py` | FastAPI server: serves the page, accepts leads, exposes `/healthz`. |
| `static/marketing/` | Drop `dashboard-hero.png` here to replace the animated hero mock. |
| `leads.db` | SQLite lead store. Git-ignored — it holds real contact data. |

### Design System

The page uses a premium dark neon aesthetic ("Neon Vigilance") with liquid-glass surfaces and glowing gradient effects. All design decisions live in CSS custom properties at the top of the `<style>` block — change tokens there rather than hard-coding values.

**Palette**

| Token | Value | Use |
| ----- | ----- | --- |
| `--bg` | `#04060D` | Page canvas |
| `--cyan` | `#22D3EE` | Primary neon / CTAs / links |
| `--violet` | `#A78BFA` | Secondary neon, gradient partner |
| `--ink` | `#EAF0FB` | Headings |
| `--ink-soft` | `#9DAECB` | Body copy |
| `--green` / `--amber` / `--red` | | **Semantic only** — tracked / warning / alert in the camera UI. Don't reuse for decoration. |

**Type** — Inter (UI), Instrument Serif (display headings, `.display`),
JetBrains Mono (labels, data, eyebrows).

Contrast is verified against the dark canvas: body copy 9.0:1, headings 20.3:1,
small muted text 5.1:1 — all pass WCAG AA, most reach AAA. If you lighten the
background or darken text, re-check before shipping.

### Liquid glass

Surfaces (`.card`, `.stat`, nav, modal) are frosted panes with a refracted edge.
Two things keep the effect alive:

1. **Something behind it to bend.** The fixed `.field-bg` and `.field-orbs`
   colour layers exist purely so the glass has content to refract. Section
   backgrounds are deliberately semi-transparent for the same reason. Darken
   them and the glass flattens into ordinary translucency.
2. **The `#lens` SVG filter**, wired in via `backdrop-filter: … url(#lens)`.

> **Browser support.** `url()` inside `backdrop-filter` is **Chromium-only**.
> Safari and Firefox fall back to the `-webkit-backdrop-filter` declaration —
> plain blur, no refraction. This is intentional graceful degradation. The
> layout, contrast and readability are unaffected.

Tuning dials: `scale` on the `#lens` filter (refraction strength) and
`.field-orbs { opacity }` (how much colour there is to refract).

### Motion

Scroll reveals, count-ups, the kinetic headline, the live camera wall and the
alert stream are all driven by a single IIFE at the bottom of the file, using
`IntersectionObserver` and one rAF-throttled scroll handler.

Every animation is disabled under `prefers-reduced-motion: reduce` (block at the
end of the stylesheet). **Add new animation there too.**

The hero camera wall is pure CSS/SVG — no video files. The detection box colour
transition (`@keyframes boxState`) is time-synced to the walking figure via a
shared `--dur` custom property; change one duration without the other and the
green→amber→red flip stops matching the person entering the restricted zone.

## How the lead form works

The callback modal (soft gate: opens on exit-intent, deep scroll, or any
"Request a callback" button) POSTs JSON to `/api/leads`:

```
{ name, email, phone, org, use_case, message, website }
```

- `website` is a **honeypot** — real users leave it empty; filled submissions are
  silently accepted but not stored.
- Name, email and phone are required; the email is format-checked.
- Rows are written to `leads.db` with the source IP and a UTC timestamp.

This field list is a contract between `landing.html` and `app.py` — change both
together.

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
