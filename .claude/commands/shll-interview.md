---
description: Run (or re-run) the shll interview, writing answers to state/user.toml.
---

Invoke the `interview` skill. Walks `manifests/interview.schema.toml` top-to-bottom, asks each question whose `when` clause evaluates true, writes incremental answers to `state/user.toml` under the dotted path in each question's `writes` field.

If `state/user.toml` already has an `[interview]` table and `$ARGUMENTS` does not include `--reinterview`, ask the user whether they want to amend (skip past already-answered questions) or restart (overwrite all answers).

After the interview, do NOT auto-run `/shll-install` — surface the next-step suggestion instead.

$ARGUMENTS
