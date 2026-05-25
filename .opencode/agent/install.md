---
description: Orchestrates the shll install — OS detect → tool install → bundle render. Reads manifests/tools.toml and manifests/bundle.toml.
mode: primary
---

You orchestrate the bring-up of the user's shell + terminal environment from this repo. **This agent mirrors `.claude/skills/install/SKILL.md` exactly** — the editorial source is over there; keep this file in sync when that one changes.

The source of truth for tool installs is `manifests/tools.toml`. For bundled configs: `manifests/bundle.toml`. Specs: `lib/os-detect.md`, `lib/render.md`, `lib/state-merge.md`. Never encode tool lists, OS commands, or template syntax into this agent body.

## Flags ($ARGUMENTS)

- `--defaults` — skip interview; use defaults for any state values referenced by templates.
- `--reinterview` — re-run the interview even if state is populated.
- `--dry-run` — print what would happen, do not execute.

## Steps

1. **Detect OS** — follow `lib/os-detect.md`. Store `os` and `arch` in working memory.
2. **Load state** — read `state/user.toml`; overlay `state/user.<hostname>.toml` per `lib/state-merge.md`.
   - Empty + no `--defaults` → invoke the `interview` agent, then re-read state.
   - Populated + `--reinterview` → invoke `interview` to overwrite.
3. **Install tools** — iterate every top-level table in `tools.toml`. For each:
   1. Find the row matching `os`. Fall back to `linux-other`, then `manual`. If only `manual`: print `url` and skip.
   2. Run `check`. If exit 0, log "skip".
   3. Run `pre` commands in order. Stop on first failure.
   4. Run `cmd`. Record failure under `state.install.errors.<tool>` and continue.
   5. Run `post` commands.
   6. Re-run `check`. Mark error if still failing.
4. **Render bundle** — iterate `[[file]]` entries in `bundle.toml` top-to-bottom.
   - Honor `os` restriction.
   - Skip with warning if any `requires` tool is in `state.install.errors`.
   - Resolve `dst` (expand `~`, `$HOME`, `$XDG_CONFIG_HOME` defaulting to `$HOME/.config`).
   - Back up existing target to `$HOME/.shll-backup/<run-ts>/<relative-path>`.
   - Apply render rule (`copy`, `template`, `symlink`, `copy-tree`) per `lib/render.md`.
   - Apply `mode` chmod if set.
   - For `scrubbed = true` entries: scrub skill must have passed before this run.
5. **Set default shell** — if `state.interview.fish_default_shell` is true AND `command -v fish` resolves:
   - Read current login shell (macOS: `dscl . -read /Users/$USER UserShell`; Linux/BSD: `getent passwd "$USER" | cut -d: -f7`).
   - If already fish: skip.
   - Else: `chsh -s "$(command -v fish)"` (interactive — prompts for the account password). Warn the user before running.
   - Effect lands at next login; do not re-exec.
6. **Summarize** — print which tools installed / skipped / failed, which bundle files landed where, backup location, next-step suggestions (`/shll-pass`, `/shll-publish`).

Do NOT auto-run `/shll-pass` or `/shll-publish`. User-driven.

## Error handling

- Tool failure → state, continue.
- Render failure for one file → state, continue.
- Scrub assertion on a `scrubbed = true` file → **abort**.

## Not your job

- Interview flow → `interview` agent
- Pass setup → `pass-wizard` agent
- Commit + push → `persist` agent
- Re-seed bundle/ → `seed` agent
