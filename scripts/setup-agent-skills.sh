#!/usr/bin/env bash
# =============================================================================
# Sentinel Website — agent skill setup
# =============================================================================
# Reinstalls the Claude Code skills used to build this site. Skills are NOT
# committed to the repo (they are ~13MB of third-party fonts, data and scripts),
# so each developer installs them locally with this script.
#
# Usage:   bash scripts/setup-agent-skills.sh
# Docs:    docs/AGENT-SETUP.md
#
# Safe to re-run: it overwrites skill folders in place and cleans up after
# itself. It only ever writes to .claude/skills/ and ~/.claude/skills/.
# =============================================================================
set -uo pipefail

DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.claude/skills"
TMP="$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/sentinel-skills-$$")"
FAILED=()

cleanup(){ rm -rf "$TMP" 2>/dev/null || true; }
trap cleanup EXIT

say(){ printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
ok(){  printf '    \033[32m✓\033[0m %s\n' "$1"; }
warn(){ printf '    \033[33m!\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------- prereqs ----
say "Checking prerequisites"
command -v git >/dev/null 2>&1 || { echo "git is required. Install it and re-run."; exit 1; }
ok "git $(git --version | awk '{print $3}')"
if command -v npx >/dev/null 2>&1; then
  ok "npx available"
  HAVE_NPX=1
else
  warn "npx not found — Node.js is needed for 2 of the skills. Install from nodejs.org"
  HAVE_NPX=0
fi
if command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
  ok "python available (needed by the ui-ux-pro-max search tool)"
else
  warn "python not found — ui-ux-pro-max's search script won't run without it"
fi

mkdir -p "$DEST"

# ------------------------------------------------- 1. ui-ux-pro-max suite ----
# 7 skills: ui-ux-pro-max, design, design-system, ui-styling, brand,
# banner-design, slides. Searchable UI/UX database (styles, palettes, fonts).
say "Installing ui-ux-pro-max suite (7 skills)"
if git clone --depth 1 -q https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git "$TMP/uiux" 2>/dev/null; then
  cp -r "$TMP/uiux/.claude/skills/." "$DEST/" && ok "installed"
else
  warn "clone failed"; FAILED+=("ui-ux-pro-max suite")
fi

# ----------------------------------------------------- 2. superpowers -------
# 31 skills: TDD, systematic debugging, planning, code review, problem-solving.
say "Installing superpowers (31 skills)"
if git clone --depth 1 -q https://github.com/obra/superpowers-skills.git "$TMP/sp" 2>/dev/null; then
  # repo nests skills by category (skills/testing/tdd/…) — flatten to skill name
  find "$TMP/sp/skills" -name SKILL.md -print0 | while IFS= read -r -d '' f; do
    d="$(dirname "$f")"; mkdir -p "$DEST/$(basename "$d")"; cp -r "$d/." "$DEST/$(basename "$d")/"
  done
  ok "installed"
else
  warn "clone failed"; FAILED+=("superpowers")
fi

# ---------------------------------------------------- 3. motion-framer ------
# Framer Motion / Motion animation reference (React-oriented, useful patterns).
say "Installing motion-framer"
# NOTE: this repo contains paths that exceed the Windows MAX_PATH limit, so the
# full checkout fails. We clone with no checkout and pull only the one folder.
if git clone --depth 1 -q --no-checkout -c core.longpaths=true \
     https://github.com/freshtechbro/claudedesignskills.git "$TMP/cds" 2>/dev/null; then
  ( cd "$TMP/cds" && git -c core.longpaths=true checkout HEAD -- .claude/skills/motion-framer 2>/dev/null )
  if [ -d "$TMP/cds/.claude/skills/motion-framer" ]; then
    mkdir -p "$DEST/motion-framer"
    cp -r "$TMP/cds/.claude/skills/motion-framer/." "$DEST/motion-framer/" && ok "installed"
  else
    warn "checkout failed"; FAILED+=("motion-framer")
  fi
else
  warn "clone failed"; FAILED+=("motion-framer")
fi

# ----------------------------------------------------- 4. task-observer -----
# Watches a work session for reusable-skill opportunities.
say "Installing task-observer"
if [ "$HAVE_NPX" = "1" ]; then
  if npx -y skills add rebelytics/one-skill-to-rule-them-all \
       --skill task-observer --agent claude-code >/dev/null 2>&1; then
    ok "installed"
  else
    warn "install failed"; FAILED+=("task-observer")
  fi
else
  warn "skipped (needs npx)"; FAILED+=("task-observer")
fi

# ------------------------------------- 5. landing-page-conversion-audit -----
# CRO auditor. Installed GLOBALLY (~/.claude/skills) so it works in any project.
say "Installing landing-page-conversion-audit (global)"
if [ "$HAVE_NPX" = "1" ]; then
  if npx -y skills add autonnel/autonnel-skills@landing-page-conversion-audit -g -y >/dev/null 2>&1; then
    ok "installed globally"
  else
    warn "install failed"; FAILED+=("landing-page-conversion-audit")
  fi
else
  warn "skipped (needs npx)"; FAILED+=("landing-page-conversion-audit")
fi

# ------------------------------------------------------------- summary ------
say "Summary"
COUNT=$(ls -1 "$DEST" 2>/dev/null | wc -l | tr -d ' ')
ok "$COUNT skills now in .claude/skills/"
if [ "${#FAILED[@]}" -gt 0 ]; then
  warn "failed: ${FAILED[*]}"
  echo "    See docs/AGENT-SETUP.md for manual install steps."
fi
cat <<'NEXT'

    Next steps
      1. Restart Claude Code in this project so it picks up the new skills.
      2. For the 21st.dev MCP server, set your OWN API key:
             setx API_KEY_21ST "your-key"     (Windows, then open a new terminal)
             export API_KEY_21ST="your-key"   (macOS/Linux, add to your shell rc)
         Get a free key at https://21st.dev — see docs/AGENT-SETUP.md.
      3. "find-skills" is not installed by this script — see docs/AGENT-SETUP.md.

NEXT
