---
description: Sets up GPG identity, initializes pass, configures git remote for password store, sets GPG agent cache TTL.
mode: subagent
---

Mirrors `.claude/skills/pass-wizard/SKILL.md`. Idempotent.

Reads `state.interview.*`. Writes `state.pass.*`.

## Steps

1. **GPG key** — list secret keys via `gpg --list-secret-keys --keyid-format=long`.
   - `state.interview.gpg_existing == "existing"`: pick a matching fingerprint (auto if `state.git.email` matches one).
   - `state.interview.gpg_existing == "generate"`: build batch param file from `state.git.{name,email}` + `state.interview.{gpg_algo, gpg_expiry}`. Run `gpg --batch --full-generate-key`.
   - Write `state.pass.gpg_key_id`.
2. **pass init** — if `~/.password-store/.gpg-id` doesn't match the chosen fingerprint, run `pass init <fingerprint>`.
3. **Git remote** — if `state.interview.pass_git_remote` is non-empty: `pass git init` + `pass git remote add origin <url>` + try-push. Write `state.pass.git_remote`.
4. **GPG agent TTL** — edit `~/.gnupg/gpg-agent.conf`: `default-cache-ttl` and `max-cache-ttl` from `state.interview.gpg_cache_ttl`. `gpgconf --reload gpg-agent`.
5. **Populate pass entries** — scan rendered configs for `pass show <path>` references. Prompt user to `pass insert` each (or skip).
6. **Finalize** — write `state.pass.initialized = true`.

## Not your job

- Installing `pass`/`gnupg` — done by `install` agent via `tools.toml`.
- Importing existing keys from another machine — user runs `gpg --import` manually first.
