---
description: Set up pass + GPG identity + git remote for the password store.
---

Invoke the `pass-wizard` skill. Steps (per the skill's SKILL.md):

1. Detect existing GPG secret keys; offer to reuse or generate.
2. If generating: run `gpg --full-generate-key --batch` with parameters from `state.interview` (algo, expiry, name, email).
3. `pass init <fingerprint>`.
4. Configure git remote for `~/.password-store` (from `state.interview.pass_git_remote`).
5. Configure `~/.gnupg/gpg-agent.conf` cache TTL.
6. For each `{{ pass:<path> }}` reference in bundle/, prompt the user to populate (or skip).
7. Write outcome to `state.pass.*`.

Idempotent — re-running checks state at each step and only does the missing work.

$ARGUMENTS
