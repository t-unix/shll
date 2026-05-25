---
name: interview
description: Walks manifests/interview.schema.toml and writes answers incrementally to state/user.toml. Use when the install skill says state is empty, or when /shll-interview is invoked.
---

# interview skill

Declarative interview driver. Reads `manifests/interview.schema.toml`, walks `[[question]]` entries top-to-bottom, writes each answer to `state/user.toml` immediately so a crash mid-interview is resumable.

## Inputs

- `--reinterview` — re-ask every question even when state has prior answers.
- `--amend` — skip questions whose `writes` path already has a value; ask only the rest.

Default behavior (no flag, no prior state): ask everything.
Default behavior (no flag, has prior state): ask `--amend`.

## For each question

1. Evaluate `when` against the current state. If false, skip silently.
2. Resolve `default` — substitute `{{ env:VAR }}`, `{{ hostname }}`, and other state references.
3. Render the prompt to the user. Show `help` if present.
4. Read the answer:
   - `bool` — yes/no.
   - `enum` — present `options`. Each may be `{label, value}` or a bare string.
   - `string` / `path` — free text. Apply `validate` regex if set; re-prompt on failure.
   - `int` — must parse as integer.
   - `secret` — read without echo; never write to state, only to working memory for this run.
5. Write the answer to `state/user.toml` at the dotted path in `writes`. Create intermediate tables as needed. Preserve other keys in the file.

## Resume

Detect resume on entry: if `state/user.toml` exists, present `--amend` summary first ("you previously answered X for git.email — keep, change, or skip the rest?"). Make it easy to bail out.

## End of interview

Write `state.interview._completed_at = <ISO8601>`. Do NOT auto-run `/shll-install` or `/shll-pass`. Surface a short summary plus next-step suggestion.
