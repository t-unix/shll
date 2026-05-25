---
description: Applies manifests/scrub.toml to files under bundle/ — transform mode (--apply) or lint mode (--lint, default).
mode: subagent
---

Mirrors `.claude/skills/scrub/SKILL.md`.

## Inputs

- `--apply` — transform mode (used by `seed` agent).
- `--lint` — lint mode (default; used by pre-commit + `persist`).
- `--files <glob>` — restrict scope.
- `--rule <id>` — restrict to one rule.

## Load rules

Parse `manifests/scrub.toml`. Each `[[rule]]`: `id`, `pattern`, `action`, action-specific fields.

Default file scope: `bundle/**/*`, excluding binary extensions.

## Lint mode

For each rule, scan in-scope files. On any match: print rule id, file, line, match, reason. Exit non-zero. Exit 0 with "clean" if nothing matched.

`action = "fail"` rules participate only in lint mode and always fail on match.

## Transform mode

- `drop-binding` — delete `^bind(-key)?\s+<bind>\s.*` lines where `<bind>` is the rule's `bind` AND the line matches `pattern`.
- `drop-line` — delete the line.
- `comment-out` — prepend `# ` (or `-- ` for `.lua`).
- `replace` — replace match with `replacement` literally. May contain `{{ pass:<path> }}`.
- `fail` — abort the transform run.

After transform, re-run lint. Surface anything still failing.

## Telemetry

End with:
```
Scrub mode: <lint|apply>
Files scanned: N
Rules applied: M
Findings: K
Status: clean | failures
```
