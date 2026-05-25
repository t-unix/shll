---
description: Commit the current state/user*.toml and push to the user's fork or downstream repo.
---

Invoke the `persist` skill. Based on `state.interview.persistence_mode`:

- **`fork`** — ensures `gh repo fork` exists; remote `origin` points at the user's fork, `upstream` points at this repo. Branch is `<gh-user>/main` (single mode) or `<gh-user>/<hostname>` (per-host mode). Commits any changes to `state/user*.toml` (and any bundle/overrides) with a one-liner message, no Claude attribution. Pushes.
- **`downstream`** — ensures `gh repo create <name>` exists; remote `origin` points at the downstream, `upstream` at this repo. Commits + pushes to `main` of the downstream.

Before committing: run the `scrub` skill in lint mode. Abort if it finds anything.

Commit message style (from user's global CLAUDE.md): one-liner, no Claude attribution.

$ARGUMENTS
