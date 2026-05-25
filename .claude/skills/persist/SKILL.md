---
name: persist
description: Commits state/user*.toml (and any user bundle overrides) and pushes to the user's fork or downstream repo. Reads state.interview.persistence_mode to choose strategy. Use when /shll-publish is invoked.
---

# persist skill

Two modes, chosen by `state.interview.persistence_mode`:

- **`fork`** — single repo, push to a user-branch on the user's fork.
- **`downstream`** — separate repo that tracks this one as upstream.

## Pre-flight

1. Run the `scrub` skill in lint mode. Abort if anything matches.
2. Read `gh auth status`. If not authenticated, run `gh auth login` (interactive).
3. `git status --porcelain`. If clean, exit with "nothing to commit".

## Mode: `fork`

1. Determine the upstream slug from `git remote get-url upstream` (or `origin` if `upstream` is unset). Parse owner/repo.
2. Check if the user's fork exists: `gh repo view <gh-user>/<repo-name>`.
   - If missing: `gh repo fork <upstream-slug> --clone=false --remote=false`.
3. Rewire remotes if needed:
   - `origin` → `git@github.com:<gh-user>/<repo>.git`
   - `upstream` → original upstream URL
4. Choose branch name:
   - `state.interview.fork_branch_strategy == "single"` → `<gh-user>/main`
   - `state.interview.fork_branch_strategy == "per-host"` → `<gh-user>/<hostname>`
5. Check out the branch (create if missing, based on `upstream/main`).
6. Stage: `state/user.toml`, `state/user.<hostname>.toml` (if exists), any user-modified files under `bundle/` (rare).
7. Commit with a one-line message — no Claude attribution. Example: `state: update from <hostname>`.
8. Push: `git push -u origin <branch>`.

## Mode: `downstream`

1. Resolve repo name from `state.interview.downstream_repo_name` (or `state.interview.persistence.downstream_repo`).
2. Check if it exists: `gh repo view <gh-user>/<name>`.
   - If missing: `gh repo create <gh-user>/<name> --private --source=. --remote=origin --push`.
3. Ensure `upstream` remote points at the original repo.
4. Commit + push to `main` of the downstream.

## Resume on a new machine

The user runs `git clone <their-repo>` then `claude /shll-install`. The install skill sees populated state, skips interview, runs install + render. No special handling needed in persist — it's only invoked from the user-driven `/shll-publish` command.

## Commit message style

One-liner. No "Co-Authored-By: Claude" or similar. (Honors user's global CLAUDE.md instruction.)

Examples:
- `state: initial bring-up on turul`
- `state: update font size to 16 on aux-monitor`
- `bundle: drop personal alias from fish/config.fish.tmpl`

## Not your job

- Pulling future upstream improvements → user runs `git fetch upstream && git rebase upstream/main` (fork) or `git pull upstream main --no-rebase` (downstream).
- Resolving merge conflicts → user, manually.
