# password-store layout (shll convention)

The shll bundle's `config.fish` (and other rendered files) reference secrets
via `{{ pass:<path> }}` template substitutions. The paths below are the
conventional layout — populate the entries the pass-wizard prompts you for,
or skip and the rendered config will leave a commented-out TODO line.

## Suggested paths

```
api/
  openai           # OPENAI_API_KEY (referenced by fish/config.fish)
  anthropic        # ANTHROPIC_API_KEY
  github           # gh CLI token (alternative to gh auth login)

ssh/
  <host>/<user>    # SSH passphrases — one entry per identity

git/
  signing-key      # GPG passphrase backup (not the key itself)
```

## Workflow

- `pass insert api/openai` — interactive: paste the secret
- `pass show api/openai` — print to stdout
- `pass show -c api/openai` — copy to clipboard (45s default)
- `pass edit api/openai` — open in $EDITOR

## Git remote

After `pass git init` + `pass git remote add origin <url>`:

- `pass git push` after each `insert`/`edit` to sync
- `pass git pull` on new machines to fetch

The pass-wizard (`/shll-pass`) sets this up once. After that you only deal
with `pass insert` / `pass show`.
