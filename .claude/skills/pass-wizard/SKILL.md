---
name: pass-wizard
description: Sets up GPG identity (existing or new), initializes pass, configures a git remote for the password store, sets GPG agent cache TTL. Use when /shll-pass is invoked or when install skill finishes and state.interview.pass_setup is true.
---

# pass-wizard skill

Idempotent. Each step checks current state first and only runs the missing work.

Reads interview answers from `state.interview.*`. Writes outcome to `state.pass.*`.

## Step 1 — GPG key

Run `gpg --list-secret-keys --keyid-format=long`. Parse fingerprints.

- If keys exist and `state.interview.gpg_existing == "existing"`: ask the user which fingerprint to use (or auto-pick if there's only one matching `state.git.email`).
- If `state.interview.gpg_existing == "generate"`:
  - Build a batch param file with: `Name-Real`, `Name-Email` (from `state.git.*`), `Key-Type` (ed25519 → `EDDSA` + Curve `ed25519`; rsa4096 → `RSA` length 4096), `Expire-Date` (from `state.interview.gpg_expiry`).
  - Run `gpg --batch --full-generate-key <paramfile>`.
  - Capture the new fingerprint.

Write `state.pass.gpg_key_id = <fingerprint>`.

## Step 2 — pass init

If `~/.password-store/.gpg-id` exists and matches the chosen fingerprint, skip.
Otherwise: `pass init <fingerprint>`.

## Step 3 — git remote (optional)

If `state.interview.pass_git_remote` is non-empty:

- `cd ~/.password-store`
- If `.git/` does not exist: `pass git init`
- If origin remote doesn't exist: `pass git remote add origin <url>`
- Try `pass git push -u origin main` (or `master` — whichever the upstream uses). On auth failure, surface the error and let the user fix.

Write `state.pass.git_remote = <url>`.

## Step 4 — GPG agent cache TTL

Edit `~/.gnupg/gpg-agent.conf`:
- Set `default-cache-ttl <seconds>` from `state.interview.gpg_cache_ttl`.
- Set `max-cache-ttl <seconds>` to the same or higher.

Run `gpgconf --reload gpg-agent`.

Write `state.pass.cache_ttl = <seconds>`.

## Step 5 — populate `{{ pass:<path> }}` references

Scan all rendered config files under `~/.config/`, `~/.tmux*.conf`, etc. for any `pass show <path>` references that came from `{{ pass:<path> }}` templates. For each path:

- Run `pass show <path>` silently. If exit 0, skip.
- Otherwise, prompt the user to populate (or skip). If populate: `pass insert <path>`.

## Step 6 — finalize

Write `state.pass.initialized = true`.

## Not your job

- Installing `pass` / `gnupg` themselves → that's the `install` skill (via `tools.toml`).
- Importing existing keys from another machine → user does this manually with `gpg --import`; the wizard then detects them in step 1.
