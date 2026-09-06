# NewVis AI — Marketing Website

Premium dark neon marketing website + lead-capture platform for **NewVis AI**, an advanced AI video-analytics solution that transforms existing CCTV cameras into intelligent real-time safety systems (schools, malls, parking, offices, warehouses, and more).

**Single-file frontend** (`landing.html`) — no build step, no framework, no bundler. Lightweight FastAPI backend (`app.py`) serves the page and stores "Request a callback" submissions in SQLite. 100% self-contained with zero dependencies on other services.

---

## 🚀 Quick Start

### Prerequisites
- **Python 3.9+** (3.10+ recommended)
- **pip** (Python package manager)
- **Git**

### Installation & Run

```bash
# 1. Clone the repository
git clone https://github.com/NewVisAI/SENTINEL-WEBSITE.git
cd SENTINEL-WEBSITE

# 2. Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run the server
uvicorn app:app --host 0.0.0.0 --port 8000
```

📱 **Open in browser:** <http://localhost:8000>

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
```bash
curl http://localhost:8000/healthz
# Expected: {"ok":true}
```

### 2. Test Lead Form
Open <http://localhost:8000> and:
- Click "Request a callback"
- Fill the form and submit
- Check `leads.db` for the submission:
```bash
sqlite3 leads.db "SELECT * FROM leads ORDER BY id DESC LIMIT 1;"
```

### 3. Check Static Files
- Hero dashboard mock: <http://localhost:8000/static/marketing/dashboard-hero.png>
- Favicon: Should load without errors

---

## 🐛 Troubleshooting

### Port 8000 Already in Use
```bash
# Use a different port
uvicorn app:app --host 0.0.0.0 --port 8001
```

### Dependencies Installation Fails
```bash
# Update pip first
pip install --upgrade pip
# Then try again
pip install -r requirements.txt
```

### Import Errors
Make sure you're in the correct directory and virtual environment is activated:
```bash
pwd  # Should show SENTINEL-WEBSITE directory
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### SQLite Database Issues
```bash
# Remove corrupted database
rm leads.db
# Server will create a fresh one on next request
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

### Production Server
```bash
# Using environment variables for production
ADMIN_KEY=your-production-secret uvicorn app:app --host 0.0.0.0 --port 8000 --workers 4
```

### Docker (Optional)
Create `Dockerfile`:
```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t newvis-website .
docker run -p 8000:8000 newvis-website
```

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
