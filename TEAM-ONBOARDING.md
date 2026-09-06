# NewVis AI — Team Onboarding Guide

Welcome to the NewVis AI development team. This guide covers codebase setup, architecture, design system, and common workflows.

---

## 1. Project Structure

```
newvis-ai-complete/
├── website-sentinel/              # Marketing website (port 8000)
│   ├── landing.html              # Complete frontend (markup + styles + JS)
│   ├── app.py                    # FastAPI backend (lead capture + static serving)
│   ├── requirements.txt           # Python dependencies
│   ├── leads.db                  # SQLite (git-ignored)
│   ├── Dockerfile                # Container image
│   └── README.md                 # Setup instructions
│
├── SENTINEL-UI/                   # Dashboard (port 8002)
│   ├── backend/
│   │   └── index.html            # Complete dashboard UI (markup + styles + JS)
│   ├── web_server.py             # FastAPI mock backend
│   ├── requirements.txt           # Python dependencies
│   ├── Dockerfile                # Container image
│   └── README.md                 # Setup instructions
│
├── docker-compose.yml            # Run both services locally
├── DEPLOYMENT.md                 # Production deployment guide
└── TEAM-ONBOARDING.md           # This file
```

---

## 2. Quick Start (5 minutes)

### Option A: Docker (Easiest)
```bash
git clone <repo>
cd newvis-ai-complete
docker-compose up -d
```
- Website: http://localhost:8000
- Dashboard: http://localhost:8002

### Option B: Manual Setup
```bash
# Website
cd "website-sentinel"
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --port 8000 &

# Dashboard (new terminal)
cd ../SENTINEL-UI
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn web_server:app --port 8002
```

**Services running?** Visit:
- http://localhost:8000 — Website homepage
- http://localhost:8002 — Dashboard login

---

## 3. Key Technologies

| Component | Tech Stack |
|-----------|-----------|
| **Website Frontend** | HTML5, CSS3, Vanilla JS (1 file) |
| **Website Backend** | FastAPI, SQLite |
| **Dashboard Frontend** | HTML5, CSS3, Vanilla JS (1 file) |
| **Dashboard Backend** | FastAPI (mock endpoints) |
| **Deployment** | Docker, Docker Compose, Nginx (prod) |
| **Python** | 3.9+ (3.10+ recommended) |

---

## 4. Design System

Both services use a **premium dark OLED theme** with neon accents:

### Color Palette
```css
--bg:               #020617   /* Navy OLED background */
--purple:           #D946EF   /* Primary neon purple */
--cyan:             #00D9FF   /* Secondary neon cyan */
--text:             #F8FAFC   /* Light text on dark */
--text-dim:         #CBD5E1   /* Secondary text */
```

### Typography
- **UI**: Inter (system fallback)
- **Display**: Instrument Serif (headers)
- **Code/Data**: JetBrains Mono

### Visual Effects
- **Glassmorphism**: `backdrop-filter: blur(40px)` on all cards
- **Glow**: `box-shadow: 0 0 40px rgba(0, 217, 255, 0.3)` (cyan)
- **Animation Easing**: `cubic-bezier(0.16, 1, 0.3, 1)` (fluid bounce)

### Where to Tweak Design
- **Website**: Edit `<style>` block at top of `landing.html` (lines ~1-400)
- **Dashboard**: Edit `<style>` block at top of `backend/index.html` (lines ~1-500)

All colors and spacing use CSS custom properties (`--purple`, `--blur`, etc.) — change tokens first, not hard-coded values.

---

## 5. Common Tasks

### Add a New Feature to Website

**Example:** Add a pricing table to the landing page

1. Open `website-sentinel/landing.html`
2. Find the `<!-- PRICING SECTION -->` in the HTML body (search for section you want)
3. Add markup inside an existing `.card` container or create new:
   ```html
   <div class="card" style="background: linear-gradient(...)">
     <h3 style="color: var(--purple);">Plan Name</h3>
     <p>Features...</p>
   </div>
   ```
4. Use existing CSS classes: `.card`, `.stat`, `.btn`, etc. (defined in `<style>`)
5. Save and refresh browser at http://localhost:8000
6. Test on mobile (resize to 375px) and tablet (768px)

### Modify Dashboard UI

**Example:** Change the card accent color from purple to another neon

1. Open `SENTINEL-UI/backend/index.html`
2. Search for `--purple: #D946EF` in the `<style>` block
3. Change value: `--purple: #FF1493` (hot pink)
4. All cards using `var(--purple)` update automatically
5. Reload http://localhost:8002

### Update Copy (Marketing Content)

**Website:**
- Hero heading: Search `"Any space. Every camera"` in `landing.html`
- Subheading: Search `"One AI watching"`
- Feature bullets: Search `"Works with existing"`

**Dashboard:**
- Page title: Search `"NewVis AI — Campus Surveillance"` in `backend/index.html`

### Add a New Lead Form Field

1. Open `website-sentinel/landing.html`
2. Find the form (search for `name="name"`)
3. Add a field:
   ```html
   <input type="text" name="budget" placeholder="Your budget" required />
   ```
4. Update `app.py` to accept the new field in the POST `/api/leads` handler:
   ```python
   class LeadSubmission(BaseModel):
       name: str
       email: str
       phone: str
       budget: str  # NEW FIELD
       ...
   ```
5. Database row automatically includes new field on next submission

### Extend Dashboard Mock Backend

Dashboard mock endpoints are in `SENTINEL-UI/web_server.py`.

**Add a new endpoint:**
```python
@app.get("/api/my-new-endpoint")
async def my_endpoint():
    return {"data": "fake response"}
```

Restart:
```bash
# Stop (Ctrl+C or docker-compose stop)
uvicorn web_server:app --port 8002
```

---

## 6. Git Workflow

### Committing Code
```bash
git status                          # See what changed
git add .                           # Stage everything
git commit -m "Brief description"   # Commit
git push origin main                # Push to GitHub
```

### Branching (Team Collaboration)
```bash
git checkout -b feature/my-feature  # Create branch
# Make changes...
git add .
git commit -m "Implement my feature"
git push origin feature/my-feature
# Create PR on GitHub
```

### Keep Local Code in Sync
```bash
git pull origin main                # Get latest changes
```

---

## 7. Testing Checklist

Before committing, test:

**Website**
- [ ] Homepage loads at http://localhost:8000
- [ ] "Request a callback" form opens
- [ ] Form submits without errors
- [ ] Lead appears in database (see README for query)
- [ ] Resize to 375px — no horizontal scroll
- [ ] Resize to 768px — layout adapts

**Dashboard**
- [ ] Login page loads at http://localhost:8002
- [ ] All cards render without broken styles
- [ ] Purple accent and cyan glow visible
- [ ] Resize to 375px — no horizontal scroll
- [ ] Console shows no JS errors (F12)

---

## 8. Database & Leads

### View Submitted Leads (Website)

```bash
sqlite3 website-sentinel/leads.db "SELECT created_at, name, email, phone, org, use_case FROM leads ORDER BY id DESC;"
```

### Export Leads to CSV
```bash
sqlite3 website-sentinel/leads.db ".mode csv" ".headers on" "SELECT * FROM leads;" > leads.csv
```

### Backup Database
```bash
cp website-sentinel/leads.db website-sentinel/leads.db.backup
```

---

## 9. Troubleshooting

### "Port 8000 already in use"
```bash
# Find and kill the process
lsof -i :8000
kill -9 <PID>

# Or use a different port
uvicorn app:app --port 8001
```

### "ModuleNotFoundError: No module named 'fastapi'"
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### "CSS changes not showing"
- Hard refresh browser: `Ctrl+Shift+R` (or `Cmd+Shift+R` on Mac)
- Clear browser cache: DevTools → Application → Clear storage → Clear site data

### "Dashboard form not working"
- Check console for JS errors: Press `F12`, click Console tab
- Verify mock backend is running: `curl http://localhost:8002/api/login`

---

## 10. Code Style & Conventions

### HTML/CSS
- Use lowercase for class names: `.hero-section` not `.HeroSection`
- CSS custom properties for colors/spacing: `var(--purple)` not `#D946EF`
- No inline styles — use CSS classes instead

### JavaScript
- Use modern ES6+ (arrow functions, template literals, const/let)
- Keep functions small and focused
- Name event handlers: `handleFormSubmit()` not `onclick=...`

### Python/FastAPI
- Follow PEP 8 (auto-format: `black app.py`)
- Type hints on function parameters: `def get_leads(limit: int = 10)`
- Use async functions for I/O: `async def api_endpoint()`

---

## 11. Resources & Getting Help

| Need | Where to Find |
|------|---------------|
| **Setup Issues** | See respective `README.md` in each directory |
| **Deployment** | `DEPLOYMENT.md` in project root |
| **API Endpoints** | Comments in `app.py` and `web_server.py` |
| **Design System** | CSS custom properties at top of each `.html` file |
| **Git Help** | GitHub docs: https://docs.github.com/en/get-started |
| **FastAPI Docs** | Run locally, visit: http://localhost:8000/docs (if enabled) |

---

## 12. Next Steps

1. **Clone & start**: `docker-compose up -d`
2. **Test website**: Submit a lead form
3. **Test dashboard**: Check login page loads
4. **Read code**: Open `landing.html` and skim the structure
5. **Try a small edit**: Change hero copy or button color
6. **Commit your change**: `git add . && git commit -m "..."`
7. **Ask questions**: Slack/email the team lead

---

## 12. Team Contacts

- **Technical Lead**: [Your Name]
- **Design**: [Designer Name]
- **DevOps**: [DevOps Engineer Name]

**Slack Channel**: #newvis-ai-dev

Welcome to the team! 🚀
