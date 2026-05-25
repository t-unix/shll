# Render syntax

Used by `manifests/bundle.toml` entries with `render = "template"`. Files with this render mode have a `.tmpl` suffix in `bundle/` and are written without that suffix at the target path.

## Variables

All variables are resolved from the merged context: `state/user.toml` + `state/user.<host>.toml` overlay + a few well-known runtime values (`os`, `arch`, `home`, `hostname`).

### `{{ os }}` / `{{ arch }}` / `{{ home }}` / `{{ hostname }}`

Runtime values from `lib/os-detect.md` + `$HOME` + `hostname -s`.

### `{{ cmd_or_super }}`

Resolves to `"Command"` on `os = macos`, `"Super"` everywhere else. Used in Alacritty TOML keyboard bindings. The double-quotes are part of the substitution because Alacritty expects a quoted TOML string.

### `{{ user.<dotted.path> }}`

Resolves a key from the merged state. Examples:

- `{{ user.git.email }}` → `flx@w3.is`
- `{{ user.terminal.font }}` → `"SauceCodePro Nerd Font"`
- `{{ user.tmux.prefix.inner }}` → `C-\`

Missing keys are a render error unless followed by `|default("...")`:

- `{{ user.font.size | default("14") }}`

### `{{ pass:<path> }}`

A reference to a secret stored in the user's `pass` store. The renderer translates this differently per target file type:

- **Fish files** (`.fish`, `.fish.tmpl`):
  `set -gx FOO {{ pass:api/openai }}` → `set -gx FOO (pass show api/openai 2>/dev/null)`
- **Bash/POSIX shell files** (`.sh`, `.bash`, `.bashrc.tmpl`):
  `export FOO={{ pass:api/openai }}` → `export FOO="$(pass show api/openai 2>/dev/null)"`
- **Non-shell files** (`.toml`, `.lua`, `.conf`):
  Leave a comment placeholder. The renderer emits a warning so the user knows the value won't auto-populate.

If the pass-wizard has not been run (i.e. `state.pass.initialized` is false), the renderer comments out the entire line containing `{{ pass:... }}` and prepends a `# TODO: pass not yet configured —` note.

### `{{ env:<NAME> }}`

Bakes the current value of an environment variable into the rendered file. Use sparingly — most things should flow through `state/user.toml` for reproducibility.

## Escaping

To emit a literal `{{`, write `\{{`. The renderer treats `\{{` as a single literal `{{` and removes the backslash.

## Render rules in `bundle.toml`

```toml
[[file]]
src     = "fish/config.fish.tmpl"
dst     = "$XDG_CONFIG_HOME/fish/config.fish"   # falls back to $HOME/.config if XDG unset
render  = "template"
requires = ["fish"]
scrubbed = true                                  # asserted by the scrub skill
```

- `render = "copy"` — byte-for-byte copy. No substitution.
- `render = "template"` — apply this syntax.
- `render = "symlink"` — symlink the target to the bundled file (read-only on the bundle path; useful for theme dirs).

## Backups

Before writing any `dst`, the renderer moves the existing file (or directory, for symlinks) to `$HOME/.shll-backup/<run-timestamp>/<relative-path>`. The renderer never deletes user files.
