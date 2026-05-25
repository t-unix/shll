---
name: scrub
description: Applies `manifests/scrub.toml` to files in `bundle/` — either as a transform (seed-time, when re-seeding from a live host) or as a lint (assert no patterns match). Use when re-seeding the bundle, or when verifying nothing has leaked into a commit.
---

# scrub skill

Two modes, same rule set (`manifests/scrub.toml`):

- **Transform mode** (`scrub --apply` or invoked by the `seed` skill): scans matched files, applies the action of each rule. Edits files in place under `bundle/`.
- **Lint mode** (`scrub --lint`, the default): scans matched files, fails if any rule matches. Used as a pre-commit hook and CI gate.

## Inputs

- `--apply` — transform mode.
- `--lint` — lint mode. Default.
- `--files <glob>` — restrict to a glob (default: everything under `bundle/`).
- `--rule <id>` — restrict to one rule by `id`.

## Loading rules

Parse `manifests/scrub.toml`. Each `[[rule]]` has `id`, `pattern`, `action`, and action-specific fields (`bind`, `replacement`, `files`, `reason`).

For each rule, compute its file scope:
- If `files` is set, use those globs.
- Otherwise, default to `bundle/**/*` (excluding binary files — skip anything matching `*.{png,jpg,jpeg,gif,ico,woff,woff2,ttf,otf,zip,tar,gz}`).

## Lint mode

For each rule, for each in-scope file, scan with the rule's regex. If any match:

- Print a structured error: rule id, file, line number, the match, the rule's `reason`.
- For rules with `action = "fail"`, this is the only mode they participate in — they always fail the lint.
- For rules with other actions (`drop-binding`, `drop-line`, `comment-out`, `replace`), a match in lint mode also fails — meaning the seed-time transform didn't fully clean. The fix is to re-run `--apply` on the affected files.

Exit non-zero if any rule matched. Exit 0 with a one-line "clean" message otherwise.

## Transform mode

For each rule, for each in-scope file, scan and transform:

- **`drop-binding`** — for tmux conf files. Delete lines matching `^bind(-key)?\s+<bind>\s` where `<bind>` is the rule's `bind` value, but only when the line also matches the rule's `pattern`. (Keeps unrelated `bind H` lines safe — though there shouldn't be any.)
- **`drop-line`** — delete the entire line containing the match.
- **`comment-out`** — prepend a comment prefix to the line. Infer the prefix from the file extension:
  - `.fish`, `.sh`, `.bash`, `.conf`, `.toml` → `# `
  - `.lua` → `-- `
  - other → `# ` (best-effort)
- **`replace`** — replace the matched text with `replacement` literally. The replacement may contain `{{ pass:<path> }}` references which render at install time.
- **`fail`** — print the match and abort the transform run. These are blanket leak detectors; they should NEVER appear in `bundle/`. If transform mode hits one, something is upstream-broken.

After transform, re-run lint mode automatically. If anything still fails, surface it.

## Telemetry output

Always end with a summary block:

```
Scrub mode: lint
Files scanned: 41
Rules applied: 12
Findings: 0
Status: clean
```

## Not your job

- Re-seeding files from `~/.config` into `bundle/` → `seed` skill (which calls this skill with `--apply`).
- Detecting new secret patterns to add → manual; add a `[[rule]]` to `scrub.toml`.
