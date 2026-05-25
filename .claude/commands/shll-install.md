---
description: Bring this machine up to the shll baseline — detect OS, install tools, render bundled configs.
---

Run the `install` skill. Pass through any of these flags from `$ARGUMENTS`:

- `--defaults` — skip interview; use defaults for any state values referenced by templates.
- `--reinterview` — re-run the interview even when state exists.
- `--dry-run` — print what would happen, don't execute.

If no `state/user.toml` exists and `--defaults` was not passed, the install skill will invoke the `interview` skill first.

Refer to:
- `CLAUDE.md` — high-level orchestration
- `.claude/skills/install/SKILL.md` — step-by-step
- `manifests/tools.toml`, `manifests/bundle.toml` — source of truth
- `lib/os-detect.md`, `lib/render.md`, `lib/state-merge.md` — specs

$ARGUMENTS
