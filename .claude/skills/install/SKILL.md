---
name: install
description: Orchestrates the shll install — OS detect → tool install → bundle render. Reads manifests/tools.toml and manifests/bundle.toml; uses lib/os-detect.md, lib/render.md, lib/state-merge.md as canonical specs. Use this when the user runs /shll-install or asks to set up their shell environment from this repo.
---

# install skill

You orchestrate the bring-up of the user's shell + terminal environment from this repo. You are thin — **never** encode tool lists, OS commands, or template syntax inside this file. The source of truth is `manifests/tools.toml` and `manifests/bundle.toml`. If something looks wrong with how a tool installs, fix the manifest, not the skill.

## Inputs

- Optional flag `--defaults` — skip the interview entirely; use defaults for any state values referenced by templates.
- Optional flag `--reinterview` — re-run the interview even if state is populated.
- Optional flag `--dry-run` — print what would happen, do not execute installs or write files.

## Steps

### 1. Detect OS

Follow `lib/os-detect.md` exactly. Store the result as `os` and `arch` in working memory. If the result is `linux-other`, warn the user that some tools may need manual install per the `manual` rows in `tools.toml`.

### 2. Load state

Read `state/user.toml` if it exists. If `state/user.<hostname>.toml` also exists, merge per `lib/state-merge.md`. Working memory now has the full state context.

- If `state.interview` is missing/empty AND `--defaults` was not passed: invoke the `interview` skill, then re-read state.
- If state has `[interview]` AND `--reinterview` was passed: invoke `interview` to overwrite.
- Otherwise: proceed to install with current state.

### 3. Install tools

Iterate every top-level table in `tools.toml` (each is one tool). For each tool:

1. Look up the row matching the detected `os`. If no row, fall back to `linux-other`, then `manual`. If only `manual` exists, print the `url` and skip.
2. Run the `check` command. If exit 0, the tool is already installed — log "skip" and move on.
3. Run any `pre` commands in order. Stop and record an error on first non-zero exit.
4. Run `cmd`. On non-zero exit, record under `state.install.errors.<tool>` and continue to the next tool — do not abort the whole run.
5. Run any `post` commands.
6. Re-run `check`. If still failing, mark error.

Use `sudo` when the command itself uses it; never wrap commands in extra `sudo`.

After all tools, write `state.install.last_run = <ISO8601>` and the per-tool error map to `state/user.<hostname>.toml`.

### 4. Render bundle

Iterate `[[file]]` entries in `bundle.toml` top-to-bottom. For each:

1. If `os` is set and doesn't match detected os, skip silently.
2. If `requires` is set and any listed tool is in `state.install.errors`, skip with a warning (the user will see the missing dependency).
3. Resolve `dst`: expand `~`, `$HOME`, `$XDG_CONFIG_HOME` (default `$HOME/.config` if unset), and any env vars.
4. If `dst` already exists, move it to `$HOME/.shll-backup/<run-timestamp>/<relative-path>`. Never delete user files.
5. Apply the render rule per `lib/render.md`:
   - `copy` — byte-for-byte copy.
   - `template` — substitute `{{ user.* }}`, `{{ pass:* }}`, `{{ cmd_or_super }}`, `{{ env:* }}`, `{{ os }}`, `{{ hostname }}`, etc. The source file has a `.tmpl` suffix; the destination drops it.
   - `symlink` — symlink `dst` → absolute path of `src` inside the cloned repo.
   - `copy-tree` — recursive copy preserving directory structure. For dirs, files inside are individually copied; existing files at the target are individually backed up.
6. If `mode` is set, `chmod` the destination accordingly.
7. If `scrubbed = true`, the `scrub` skill must have passed before this run started. Do not re-run scrub here — that's the seed/lint workflow.

### 5. Post-install hand-off

Print a short summary:
- Which tools were newly installed vs already present vs failed.
- Which bundle files landed where.
- Backup location.
- Next steps the user should run themselves: `/shll-pass` if they answered yes to `pass_setup`; `/shll-publish` to commit + push state; otherwise nothing.

Do NOT auto-run `/shll-pass` or `/shll-publish`. Those are separate user-driven commands.

## Error handling

- Tool install failure → record in state, continue with next tool. Render still runs for everything that installed successfully.
- Bundle render failure for one file → record, continue. The user can re-run.
- Scrub assertion failure on a `scrubbed = true` file → **abort**. The bundle has a leak that needs fixing upstream.

## Not your job

- Interview flow → `interview` skill
- Pass / GPG setup → `pass-wizard` skill
- Committing + pushing state → `persist` skill
- Re-seeding `bundle/` from a live host → `seed` skill
