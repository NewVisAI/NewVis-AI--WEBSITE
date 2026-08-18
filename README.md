# Sentinel AI — Marketing Site

A self-contained marketing website + lead-capture form for **Sentinel AI**, the
general-purpose AI video-analytics platform by **Adiva** that turns existing CCTV
cameras into real-time safety intelligence (schools, malls, parking, offices,
warehouses, and more).

The page is a single `landing.html` — no build step, no framework, no bundler.
A tiny FastAPI backend (`app.py`) serves it and stores "Request a callback"
submissions in a local SQLite database, with no dependency on the main Sentinel
product code.

## Run locally

```bash
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8000
```

Open <http://localhost:8000>.

## Working on this with Claude Code

The AI tooling used to build this page (design-system skills, animation
references, the 21st.dev MCP server) is **not** committed — it is ~13MB of
third-party content. To get the same setup on your machine:

```bash
bash scripts/setup-agent-skills.sh
```

See **[docs/AGENT-SETUP.md](docs/AGENT-SETUP.md)** for the full guide, including
how to get your own API keys. None of this is needed to just run the site.

## Project layout

| Path | What it is |
| ---- | ---------- |
| `landing.html` | The entire front end — markup, styles and JS in one file. Read the comment block at the top before editing. |
| `app.py` | FastAPI server: serves the page, accepts leads, exposes `/healthz`. |
| `static/marketing/` | Drop `dashboard-hero.png` here to replace the animated hero mock. |
| `leads.db` | SQLite lead store. Git-ignored — it holds real contact data. |

## Design system

The page uses a dark neon aesthetic ("Neon Vigilance") with a liquid-glass
surface treatment. All design decisions live in CSS custom properties at the top
of the `<style>` block — change tokens there rather than hard-coding values.

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

## Before you ship a change

- Check at 375 / 768 / 1024 / 1440 px — no horizontal scroll at any width.
- Test the lead form end-to-end (submit, then confirm the row lands in `leads.db`).
- Toggle "reduce motion" in your OS and confirm the page is still readable and static.
- Keep copy honest — see below.

## Notes

- `leads.db` is git-ignored — it holds real contact data and must not be committed.
- `.claude/` is git-ignored: local agent tooling, not part of the product.
- Copy is intentionally honest: Production features are stated plainly; Beta
  features (fall, running, fight, cross-camera Re-ID) are labelled as Beta and no
  unmeasured accuracy numbers are published. **Please preserve this** — the
  Production/Beta split and the measured-numbers-only rule are a deliberate
  positioning choice, not placeholder text.
