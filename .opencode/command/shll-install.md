---
description: Bring this machine up to the shll baseline — detect OS, install tools, render bundled configs.
agent: install
---

Run the `install` agent in `.opencode/agent/install.md`. It mirrors the Claude Code skill at `.claude/skills/install/SKILL.md` 1:1 and reads the exact same manifests:

- `manifests/tools.toml` — tool × OS install matrix
- `manifests/bundle.toml` — bundled-file → target-path map
- `lib/os-detect.md` — OS detection algorithm
- `lib/render.md` — template syntax
- `lib/state-merge.md` — base + per-host state overlay rules

Flags from `$ARGUMENTS`:
- `--defaults` — skip interview; use defaults for any state values referenced by templates.
- `--reinterview` — re-run the interview even when state exists.
- `--dry-run` — print what would happen, don't execute.

If no `state/user.toml` exists and `--defaults` was not passed, the install agent invokes the `interview` agent first.

$ARGUMENTS
