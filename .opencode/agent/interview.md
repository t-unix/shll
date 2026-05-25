---
description: Walks manifests/interview.schema.toml and writes answers incrementally to state/user.toml.
mode: subagent
---

Mirrors `.claude/skills/interview/SKILL.md`. Source of truth is `manifests/interview.schema.toml`.

## Flags

- `--reinterview` — re-ask every question.
- `--amend` — skip questions whose `writes` path already has a value.

Default: ask everything on fresh state; amend on populated state.

## For each question

1. Evaluate `when` against current state. Skip if false.
2. Resolve `default` (substitute `{{ env:VAR }}`, `{{ hostname }}`, state refs).
3. Render prompt + `help`.
4. Read answer per `type` (bool / enum / string / path / int / secret). Apply `validate` regex; re-prompt on failure. Never persist `secret` values to state.
5. Write answer to `state/user.toml` at the dotted `writes` path.

Resume detection: if `state/user.toml` exists, show summary first, ask whether to amend / restart / cancel.

End: write `state.interview._completed_at`. Do not auto-run anything else.
