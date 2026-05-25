---
description: Commits state/user*.toml and pushes to the user's fork or downstream repo per state.interview.persistence_mode.
mode: subagent
---

Mirrors `.claude/skills/persist/SKILL.md`.

## Pre-flight

1. Run the `scrub` agent in lint mode. Abort on any match.
2. `gh auth status` — `gh auth login` if needed.
3. `git status --porcelain` — exit "nothing to commit" if clean.

## Mode: `fork`

1. Parse upstream owner/repo from `git remote get-url upstream` (or `origin`).
2. `gh repo view <gh-user>/<repo>` — create with `gh repo fork` if missing.
3. Rewire `origin` to the fork URL, `upstream` to the original.
4. Branch:
   - `state.interview.fork_branch_strategy == "single"` → `<gh-user>/main`
   - `state.interview.fork_branch_strategy == "per-host"` → `<gh-user>/<hostname>`
5. Check out (create from `upstream/main` if missing).
6. Stage `state/user.toml`, `state/user.<hostname>.toml`, any user-modified bundle files.
7. Commit with one-line message, no AI attribution.
8. `git push -u origin <branch>`.

## Mode: `downstream`

1. Resolve repo name from `state.interview.downstream_repo_name`.
2. `gh repo view <gh-user>/<name>` — `gh repo create --private --source=. --remote=origin --push` if missing.
3. Ensure `upstream` remote points at the original.
4. Commit + push to `main` of downstream.

## Commit style

One-liner, no Claude/AI attribution (user's global CLAUDE.md rule).
