# Agent Setup — Claude Code, skills & API keys

Everything a new developer needs to get the same AI tooling that was used to
build this site. Nothing here is required to **run** the website — see the main
[README](../README.md) for that. This is only for working on it with Claude Code.

---

## Why isn't this in the repo already?

Claude Code skills are plain files on disk, in one of two places:

| Location | Scope |
| -------- | ----- |
| `.claude/skills/` | This project only |
| `~/.claude/skills/` | Every project on your machine |

Both are **git-ignored here on purpose**. The full skill set is ~13MB of
third-party fonts, datasets and scripts under assorted licences (OFL, CC BY 4.0,
MIT). Committing it would bloat this repo's history permanently and mix
third-party content into the product. Install it locally instead — it takes a
minute.

> **Signing into the same Claude account does not sync skills.** They are files,
> not account settings. Every developer installs them on their own machine.
> Claude's *memory* is per-machine too — it does not travel with the account or
> the repo.

---

## Quick start

```bash
bash scripts/setup-agent-skills.sh
```

Then **restart Claude Code** in this project so it picks up the new skills.

Prerequisites: **git** (required), **Node.js/npx** (for 2 skills), **Python 3**
(for the ui-ux-pro-max search tool). The script checks all three and tells you
what is missing.

The script is safe to re-run — it overwrites skill folders in place and only
writes to `.claude/skills/` and `~/.claude/skills/`.

---

## What gets installed

**40 project skills** into `.claude/skills/`, plus 1 global skill.

| Skill set | Count | What it is for | Source |
| --------- | ----- | -------------- | ------ |
| **ui-ux-pro-max** + `design`, `design-system`, `ui-styling`, `brand`, `banner-design`, `slides` | 7 | Searchable UI/UX database — 84 styles, 192 palettes, 74 font pairings, UX guidelines. This is where the site's design system came from. | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) |
| **superpowers** | 31 | Development methodology — TDD, systematic debugging, root-cause tracing, planning, code review, problem-solving techniques. | [obra/superpowers-skills](https://github.com/obra/superpowers-skills) |
| **motion-framer** | 1 | Motion / Framer Motion animation reference: variants, gestures, layout animations, spring physics. | [freshtechbro/claudedesignskills](https://github.com/freshtechbro/claudedesignskills) |
| **task-observer** | 1 | Watches a work session and flags patterns worth turning into reusable skills. | [rebelytics/one-skill-to-rule-them-all](https://github.com/rebelytics/one-skill-to-rule-them-all) |
| **landing-page-conversion-audit** | 1 (global) | CRO audit for landing pages — conversion leaks ranked by likely revenue impact. Useful on this repo specifically. | [autonnel/autonnel-skills](https://skills.sh/autonnel/autonnel-skills/landing-page-conversion-audit) |

### One skill the script does **not** install: `find-skills`

`find-skills` (helps discover and install more skills via the `npx skills` CLI)
was added by hand from a pasted file, so its exact upstream source is unverified.
Rather than install a lookalike that might behave differently, the script skips
it. If you want it, browse the public options and pick one:

```bash
npx skills find "find skills discover install"
```

Everything it does can also be done directly:

```bash
npx skills find <query>
```

```bash
npx skills add <owner/repo@skill>
```

```bash
npx skills add <owner/repo@skill> -g -y
```

---

## Manual install (if the script fails)

Run these from the repo root.

**1 — ui-ux-pro-max suite (7 skills)**

```bash
git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git /tmp/uiux && cp -r /tmp/uiux/.claude/skills/. .claude/skills/
```

**2 — superpowers (31 skills).** The repo nests skills by category, so flatten
them to one folder per skill name:

```bash
git clone --depth 1 https://github.com/obra/superpowers-skills.git /tmp/sp && find /tmp/sp/skills -name SKILL.md | while read f; do d=$(dirname "$f"); mkdir -p ".claude/skills/$(basename "$d")"; cp -r "$d/." ".claude/skills/$(basename "$d")/"; done
```

**3 — motion-framer.** Sparse checkout, because the full repo contains paths
that exceed the Windows path-length limit:

```bash
git clone --depth 1 --no-checkout -c core.longpaths=true https://github.com/freshtechbro/claudedesignskills.git /tmp/cds && (cd /tmp/cds && git -c core.longpaths=true checkout HEAD -- .claude/skills/motion-framer) && mkdir -p .claude/skills/motion-framer && cp -r /tmp/cds/.claude/skills/motion-framer/. .claude/skills/motion-framer/
```

**4 — task-observer**

```bash
npx skills add rebelytics/one-skill-to-rule-them-all --skill task-observer --agent claude-code
```

**5 — landing-page-conversion-audit (global)**

```bash
npx skills add autonnel/autonnel-skills@landing-page-conversion-audit -g -y
```

---

## API keys

### 21st.dev — the only key this project needs

[21st.dev](https://21st.dev) provides the **Magic MCP** server, an AI UI-component
generator. It is already configured in [`.mcp.json`](../.mcp.json), which *is*
committed. The key itself is **not** committed — it is read from an environment
variable.

**1 — Get a key.** Sign in at <https://21st.dev>, open the Magic MCP console (try
<https://21st.dev/magic/console>), and copy your API key. **Use your own
account** — see the quota warning below.

**2 — Set it as an environment variable.**

Windows (Command Prompt or PowerShell), then open a **new** terminal:

```bash
setx API_KEY_21ST "your-key-here"
```

macOS / Linux — add this to `~/.zshrc` or `~/.bashrc` so it persists:

```bash
export API_KEY_21ST="your-key-here"
```

> `setx` only affects terminals and apps opened **after** it runs. You must fully
> close and reopen Claude Code, not just open a new tab.

**3 — Restart Claude Code** in this project. It reads `.mcp.json`, sees the
`21st` server, and asks you to approve it once. Say yes.

**4 — Verify.** In Claude Code:

```bash
claude mcp list
```

You want `21st` showing **connected**. If it shows failed, the environment
variable almost certainly was not visible when the app launched — close Claude
Code completely and reopen it.

#### Free-tier limits — please read

| Action | Cost |
| ------ | ---- |
| Search, browse, list, metadata | **Free and unlimited** |
| `get_component` (pulling a component's actual code) | **Metered — 2 per day** on the free tier |

Only fetching component *code* is metered. Browsing is free, so explore freely and
spend a retrieval only once you have decided on a specific component.

**Do not share one key across the team.** The quota is per-account: if two people
use the same key, they share 2 retrievals per day. Each developer should create
their own free account.

To check remaining quota, ask Claude to run the 21st `get_usage` tool.

### Anything else?

No other keys are needed. To be explicit:

- **The website itself needs no API keys** to run — see the main README.
- `ADMIN_KEY` in the main README is **not** an external API key. It is a secret
  you invent yourself to unlock the `GET /api/leads` endpoint locally.
- The skills are all local files — no keys, no network calls at runtime.
- Claude Code needs your normal Claude account login, nothing project-specific.

---

## Never commit secrets

`.mcp.json` is committed **only** because it holds a placeholder
(`${API_KEY_21ST}`) rather than a real key. Keep it that way.

If you ever paste a real key into a file, add that file to `.gitignore` **before**
committing. If a key does get committed, treat it as compromised: revoke and
regenerate it at the provider. Deleting the line is not enough — git history
keeps it.

---

## Troubleshooting

| Problem | Fix |
| ------- | --- |
| Skills do not appear in Claude Code | Restart Claude Code fully. Skills are read at startup. |
| `21st` shows disconnected | The env var was not set when the app launched. Check with `echo %API_KEY_21ST%` (Windows) or `echo $API_KEY_21ST`, then fully restart Claude Code. |
| "Filename too long" cloning claudedesignskills | Expected on Windows. Use the sparse-checkout command above, or run `git config --global core.longpaths true`. |
| ui-ux-pro-max search script errors | It needs Python 3. Try `python3` or `py -3` if `python` is not found. |
| `npx skills` hangs on first run | It is downloading the CLI. Give it a minute, or pre-install with `npm i -g skills`. |
| Ran out of 21st retrievals | You get 2/day on the free tier and it resets. Browsing and searching stay free. |

---

## What carries over, and what does not

| Travels with the repo | Stays on your machine |
| --------------------- | --------------------- |
| Product code | Installed skills (`.claude/skills/`, `~/.claude/skills/`) |
| `.mcp.json` (server config, no key) | Your `API_KEY_21ST` |
| This document | Claude's memory of past sessions |
| `.gitignore` rules | Your Claude account login |

So the full path to parity is: clone the repo, run the setup script, set your own
21st key, restart Claude Code.
