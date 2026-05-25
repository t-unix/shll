---
name: seed
description: Re-seeds bundle/ from the current host's live config (~/.config/<tool>, ~/.tmux*.conf, ~/bin/wezterm-outer-tmux.sh, ~/.local/share/omf/themes/insh). Applies scrub.toml transforms before writing into bundle/. Use when you want to refresh the bundle from a working machine — never auto-runs.
---

# seed skill

**Manual-only.** This skill never runs as part of `/shll-install`. It exists for the user (or you, on the user's explicit request) to refresh `bundle/` from a known-good live host after they've improved their config.

## Steps

1. Map source → bundle destination (inverse of `bundle.toml`):
   - `~/.config/fish/config.fish` → `bundle/fish/config.fish.tmpl` (becomes a template; preserved {{ ... }} markers from prior version)
   - `~/.config/fish/lib/*.fish` → `bundle/fish/lib/`
   - `~/.config/fish/functions/*.fish` → `bundle/fish/functions/` (excluding `fish_prompt.fish` if it's an OMF symlink — handled separately below)
   - `~/.local/share/omf/themes/insh/` → `bundle/fish/themes/insh/` (full tree)
   - `~/.config/alacritty/alacritty.toml` → `bundle/alacritty/alacritty.toml.tmpl`
   - `~/.config/wezterm/wezterm.lua` → `bundle/wezterm/wezterm.lua`
   - `~/.tmux.conf`, `~/.tmux-outer.conf`, `~/.tmux-style.conf`, `~/.tmux-remote.conf` → `bundle/tmux/`
   - `~/bin/wezterm-outer-tmux.sh` → `bundle/bin/`
   - `~/.config/nvim/init.lua`, `lazy-lock.json`, `lua/` → `bundle/nvim/`

2. For files marked `template` in `bundle.toml`:
   - Preserve any `{{ ... }}` markers from the previous bundle version. Specifically: if the live host has `set -gx OPENAI_API_KEY sk-...` and the prior bundle had `{{ pass:api/openai }}`, keep the template marker, do NOT overwrite with the literal.
   - For new lines that don't exist in the prior bundle, the live value is taken verbatim — the scrub pass will catch leaks.

3. Run the `scrub` skill in transform mode (`--apply`) against the newly written `bundle/` files.

4. Re-run `scrub --lint`. Abort and report if anything still matches.

5. Print a diff summary of what changed in `bundle/` vs the prior commit.

## Inputs

- `--dry-run` — show the diff without writing.

## Safety

- Never touches files outside `bundle/`.
- Never reads from random paths — only the explicit source list above.
- Always runs scrub-then-lint before declaring success.

## When NOT to use

- On a fresh machine where the live config is the just-installed bundle — that's circular.
- To "import" a partially-broken config — fix it on the live host first, then seed.
