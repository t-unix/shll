---
description: Commit state/user*.toml and push to the user's fork or downstream repo.
agent: persist
---

Invoke the `persist` agent. Reads `state.interview.persistence_mode` to pick fork-and-branch or downstream-repo. Runs scrub-lint pre-flight. Mirrors `.claude/skills/persist/SKILL.md`.

Commit message style (from user's global CLAUDE.md): one-liner, no AI attribution.

$ARGUMENTS
